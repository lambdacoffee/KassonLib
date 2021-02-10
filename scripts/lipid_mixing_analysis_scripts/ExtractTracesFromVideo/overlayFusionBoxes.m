% -------
% PURPOSE
% -------
%
% This script can be run to extract the boxes around the identified 
% particles from Bob's analysis & draw them on the source video.
%
% --------
% CONTENTS
% --------
%
% function extractFusionBoxes()
%       - main driving function
% function formBoxesOverlay()
%       - forms matrix with drawn boxes to overlay on source video frame
% function getBoxes()
%       - extracts box coordinates from output of Bob's Analysis (Test.mat)
% function drawSquares()
%       - draws a box on the blank image matrix to be overlayed

function overlayFusionBoxes(src_vid_filepath, trace_filepath, dst_filepath)
    % This is the main driving function for this script.
    % This will prompt the User for 2 inputs via file selector box.
    % Input 1: User must specify the output of Bob's analysis.
    %          - this will be the << ./Analysis/Test.mat >> file
    % Input 2: User must specify the corresponding source video.
    %
    %       *** Note: User can specify whether black or white
    %                 boxes will be drawn by changing the
    %                 value of the variable `white_boxes` on
    %                 line {46}.
    %
    % Outputs (in parent directory of source video):
    %       - either whiteBoxedVid.tiff or blackBoxedVid.tiff
    %       - boxData.txt - write file for box coordinates
    
    white_boxes = 1;    % 1=white, 0=black    
    [boxy_vid_dir, filename, ~] = fileparts(dst_filepath);
    
    tic;    % for performance metrics
    tiff_info = imfinfo(src_vid_filepath);
    % tiff_info.ColorType : 'grayscale'
    num_frames = length(tiff_info);
    bit_depth = tiff_info.BitDepth;
    width = tiff_info.Width;
    height = tiff_info.Height;
    
    box_data_txt_filename = strcat(filename, "_boxData" , ".txt");
    file_id = fopen(fullfile(boxy_vid_dir, box_data_txt_filename), 'w');
    boxes_overlay = formBoxesOverlay(trace_filepath, height, width, file_id);
    
    for i=1:num_frames
        single_frame = imread(src_vid_filepath, i);     % class : uint16
        upper_threshold = 95;
        new_max = prctile(single_frame, upper_threshold, [1,2]);
        single_frame(single_frame > new_max) = new_max;
        if white_boxes
            % 50 seems to be adequate for distinguishing intensities
            % visually, though this number can be changed.
            if 2^bit_depth-1-new_max >= 50
                single_frame(boxes_overlay == -1) = new_max + 50;
            else
                single_frame(boxes_overlay == -1) = new_max;
            end
        else
            curr_min = min(min(single_frame));
            if curr_min >= 50
                single_frame(boxes_overlay == -1) = curr_min - 50;
            else
                single_frame(boxes_overlay == -1) = 0;
            end
        end
        imwrite(single_frame, dst_filepath, 'tiff', 'writemode', 'append');
    end
    
    disp(strcat("Successfully boxified ", src_vid_filepath));
    toc;    % for performance metrics
end

function boxes_overlay = formBoxesOverlay(source_structure_filepath, height, width, file_id)
    % This is called from the main driving function.
    %
    % Returns:
    %       - 2D matrix `boxes_overlay`, a blank matrix with boxes drawn as
    %         pixel values set to an overwrite value (-1, usually).
    
    boxmat = getBoxes(source_structure_filepath, file_id);
    sz = size(boxmat);      % n-by-4, n is index of boxes
    boxes_overlay = zeros(height, width);
    overwrite_val = -1;
    for i=1:sz(1)
        w = boxmat(i,3)-boxmat(i,1);
        boxes_overlay = drawBoxes(boxes_overlay, boxmat(i,1), boxmat(i,2), w, overwrite_val);
    end
end

function boxmat = getBoxes(filepath, file_id)
    % This is called by function formBoxesOverlay().
    %
    % Returns:
    %       - 2D n-by-4 matrix with each box index as the 1st dimension
    %         & the left, top, right, bottom positions as the 2nd
    %         dimension.
    
    test_structure = load(filepath);
    data_struct = test_structure.DataToSave.CombinedAnalyzedTraceData;
    sz = size(data_struct);
    boxmat = zeros(sz(2), 4);
    
    % Past this point, writing box positions to boxData.txt for
    % verification purposes, not necessary for functionality.
    
    fprintf(file_id, 'Left,Top,Right,Bottom\n\n');
    for i=1:sz(2)
        box = data_struct(i).BoxAroundVirus;
        boxmat(i,1) = box.Left;
        boxmat(i,2) = box.Top;
        boxmat(i,3) = box.Right;
        boxmat(i,4) = box.Bottom;
        line = sprintf('%d,', boxmat(i,:));
        line = strcat(line(1:end-1), '\n');
        fprintf(file_id, line);
    end
    fclose(file_id);
end

function overlay = drawBoxes(overlay, left_column, top_row, width, overwrite_value)
    % This is called from function formBoxesOverlay()
    %
    % Returns:
    %       - 2D matrix `overlay` with a new box drawn over the original by
    %         overwriting values for each box.

    overlay(top_row, left_column) = overwrite_value; % top-left corner
    for i=1:width-1
        overlay(top_row, left_column + i) = overwrite_value;
        overlay(top_row+i, left_column) = overwrite_value;
    end
    % bottom-right corner
    overlay(top_row+width-1, left_column+width-1) = overwrite_value;
    for i=1:width-1
        overlay(top_row+width-1, left_column+width-1-i) = overwrite_value;
        overlay(top_row+width-1-i, left_column+width-1) = overwrite_value;
    end
end
