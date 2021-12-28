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

function overlayFusionBoxes(trace_filepath, dst_filepath)
    % This is the main driving function for this script.
    % This will prompt the User for 2 inputs via file selector box.
    % Input 1: User must specify the output of Bob's analysis.
    %          - this will be the << ./Analysis/Test.mat >> file
    % Input 2: User must specify the corresponding source video.
    %
    % Outputs (in parent directory of source video):
    %       - either whiteBoxedVid.tiff or blackBoxedVid.tiff
    %       - boxData.txt - write file for box coordinates
    [box_data_dir, filename, ~] = fileparts(dst_filepath);
    box_data_txt_filename = strcat(filename, "_boxData" , ".txt");
    file_id = fopen(fullfile(char(box_data_dir), char(box_data_txt_filename)), 'w');
    boxmat = getBoxes(trace_filepath, file_id);
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
    
    fprintf(file_id, 'Label,Left,Top,Right,Bottom,Designation\n\n');
    row_count = 0;
    for i=1:sz(2)
        row_count = row_count + 1;
        designation = convertCharsToStrings(data_struct(i).Designation);
        if data_struct(i).isExclusion == 1
            designation = "-1";
        end
        box = data_struct(i).BoxAroundVirus;
        boxmat(i,1) = box.Left;
        boxmat(i,2) = box.Top;
        boxmat(i,3) = box.Right;
        boxmat(i,4) = box.Bottom;
        line = sprintf('%d,', i, boxmat(i,:));
        line = strcat(line(1:end-1), ",", designation, "\n");
        fprintf(file_id, line);
    end
    boxmat = boxmat(row_count, :);
    fclose(file_id);
end
