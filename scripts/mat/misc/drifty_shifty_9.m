% Reads a TEM movie file or image sequence, computes shift of image vs first frame,
%corrects by wrapping or padding, saves as uncompressed avi
% Josh Sugar and Dave Robinson, Sandia National Labs
%Copyright 2014 Sandia Corporation. Under the terms of Contract DE-AC04-94AL85000,
%there is a non-exclusive license for use of this work by or on behalf of the U.S. Government.
%Export of this program may require a license from the United States Government.

%Please cite the Microscopy Today article _blank_ if you use this script.
%***********************************************************************************************
%InputForm = questdlg('What is your input file format?','Input format','PNG','TIF','Movie','Movie');

InputForm = 'TIF';

% Image sequence can be generated from quicktime pro.
% TIFF, when uncompressed, runs faster in both quicktime and matlab.
% TIFF Packbits compression in quicktime doesn't do much for TEM images.
% PNG uses lossless compression, so is more efficient with disk space,
% especially useful if you run quicktime pro on another computer and
% transfer files via USB drive.
% Quicktime tends to choke when reassembling long image sequences into a movie.
% This version generates uncompressed AVI output.

% For movies:
% Containers supported: .avi, .mpg, .mj2 (extremely obscure)
% Windows only: .wmv, .asf, .asx
% Mac only: .mp4, .mov
% Codecs supported: good luck - generally only obsolete ones.
% Microsoft DirectShow codecs include:
% Cinepak, DV, H.264 (MS MP2), ISO MP4 1.0, MS MP4 v3, MJPEG, MP1, MP2

% Bug: sometimes the shifts are off by one width or height, resulting in
% excessive padding in 'pad' mode (innocuous in 'wrap' mode).

% x domain shift f(x-a) transforms to F(w)exp(-iaw)
% Find a, given f(x) and f(x-a)
% F(w)*conj(F(w)exp(-iaw)) gives |F(w)|^2*exp(iaw) (keeping shift but discarding phase info in image)
% ifft of |F(w)| is maximum at zero because all components are in phase there.
% ifft of the whole thing is shifted by a, so identify the location of the maximum.

%% Step 1: Calculate shift x,y pairs for each frame

% Open Files
filepath_arr = {"D:\ImagingDataSets\20211210-Marcos\Ch2_ctrl_trypsin-200ug\Ch2_green_virus_ex150ms_LI3_2\Ch2_green_virus_ex150ms_LI3_2_MMStack_Default.ome-002.tif", ...
    "D:\ImagingDataSets\20211210-Marcos\Ch4_ACE2_typsin-200ug\Ch4_green_virus_ex150ms_LI3_1\Ch4_green_virus_ex150ms_LI3_1_MMStack_Default.ome-003.tif" ...
    };

 % Set up input file
for f=1:length(filepath_arr)
    stackpath = char(filepath_arr{f});
    tiff_info = imfinfo(stackpath); % return tiff structure, one element per image
    num_images = numel(tiff_info);
    tiff_stack = imread(stackpath, 1); % read in first image
    [pardir, filename, ext] = fileparts(stackpath);
    disp(strcat("Processing: ", filename, ext))

    nFrames = num_images;

    shifty = zeros(nFrames,1);
    shiftx = zeros(nFrames,1);

    % Get reference frame (first one in the sequence)
    frameref = imread(stackpath, 1);

    imageref = frameref(:,:,1);
    fft_ref = fft2(imageref); 

    [vidHeight, vidWidth, blank] = size(frameref); % The blank variable here gets rid of extra padding !!!!!!!!!!!!!!!!!!!!!!!!!!!!
    centery = (vidHeight/2) + 1;
    centerx = (vidWidth/2) + 1;

    wb = waitbar(0, 'Please Wait... Calculating Drift...');
    for i=1:num_images
        % image sequence
        imagei = imread(stackpath, i);
        framei = imagei(:,:,1);
        fft_frame = fft2(framei);
        prod = fft_ref.*conj(fft_frame);
        cc = ifft2(prod);
        [maxy, maxx] = find(fftshift(cc) == max(max(cc)));
        % fftshift moves corners to center; max(max()) gives largest element; find returns indices of that point

        shifty(i) = maxy(1) - centery;
        shiftx(i) = maxx(1) - centerx;
        % previous version didn't subtract center point here
        if i > 1 % Checks to see if there is an ambiguity problem with FFT because of the periodic boundary in FFT
            if abs(shifty(i) - shifty(i-1)) > vidHeight/2
                shifty(i) = shifty(i) - sign(shifty(i) - shifty(i-1)) * vidHeight;
            end
            if abs(shiftx(i) - shiftx(i-1)) > vidWidth/2
                shiftx(i) = shiftx(i) - sign(shiftx(i) - shiftx(i-1)) * vidWidth;
            end
        end
        if mod(i,200) == 0
            fprintf("%d frames of %d done\n", i, nFrames);
            waitbar(i/nFrames, wb);
        end
    end % i loop
    close(wb);
    % save results to file
    shiftdatafilename = fullfile(pardir, strcat('driftdata_', filename,'.mat'));
    save(shiftdatafilename,'nFrames','shifty','shiftx','stackpath');

    disp('I finished calculating the drift data.  It was saved to:')
    disp(shiftdatafilename)

    %% Step 2: apply shift to movie frames
    shiftmode = 'Wrap';
    avgframes = 1;
    bigIter = nFrames + 1;
    shiftfile = shiftdatafilename;
    load(shiftfile);

    % Read folder to get basic info
    % image sequence
    %nFrames = length(files);
    framerate = 29.97;

    % get height and width from first image
    frameref=imread(stackpath, 1);
    %frameref=imread(fullfile(inputpath,files(1).name),filetype);
    frameref=uint16(frameref(:,:,1));
    [vidHeight, vidWidth] = size(frameref); % The blank variable here gets rid of extra padding !!!!!!!!!!!!!!!!!!!!!!!!!!!!

    if strncmp(shiftmode,'Pad',3)
        newsizey = 2 * max(abs(shifty)) + vidHeight;
        newsizex = 2 * max(abs(shiftx)) + vidWidth;
        % assumes max positive shift = max negative shift; centers reference frame
        midindexy = (newsizey-vidHeight) / 2+1;
        midindexx = (newsizex-vidWidth) / 2+1;
    else
        % wrap
        newsizey = vidHeight;
        newsizex = vidWidth;
        midindexy = 1; % these won't be used
        midindexx = 1;
    end

    for j=1:floor(nFrames/bigIter)+1
        sprintf("\nMovie file %d\n", j);
        if floor(nFrames/bigIter) + 1 == 1
            k = 1;
            bigIter = nFrames;
        end
        if j == 1
            k = 1;
        elseif j == floor(nFrames/bigIter) + 1
            k = (j-1) * bigIter + 1;
            bigIter = mod(nFrames, 2000);
        else
            k = (j-1) * bigIter + 1;
        end

        % Create array of 8-bit grayscale frame structures
        clear mov_shift
        numofframes = floor(bigIter/avgframes) - 1;
        mov_shift(1:numofframes)=struct('cdata', zeros(newsizey, newsizex, 1, 'uint16'), ...
            'colormap', [linspace(0,1,256)',linspace(0,1,256)',linspace(0,1,256)']);
        disp(strcat('I allocated the new movie structure as: ', 'drifted_', filename, '.tif'))

        % Process each frame
        for i=1:numofframes+1
            frame_sum=zeros(newsizey,newsizex,'uint16');
            for z=1:avgframes
                zz = k + (i-1) * avgframes + z-1;
                if zz > nFrames
                    continue;
                end
                imagei = imread(stackpath, zz);
                framei = uint16(imagei(:,:,1));
                if strncmp(shiftmode, 'Pad', 3)
                    frame_shift = zeros(newsizey,newsizex,'uint16');
                    frame_shift(midindexy+shifty(zz):midindexy+shifty(zz)+(vidHeight-1),...
                    midindexx+shiftx(zz):midindexx+shiftx(zz)+(vidWidth-1)) = framei;
                    frame_sum=frame_sum + uint16(frame_shift);
                else
                % Wrap
                frame_sum = frame_sum+uint16(circshift(framei,[shifty(zz) shiftx(zz)]));
                end % if pad or wrap
            end % z loop
            mov_shift(i).cdata=uint16(round(frame_sum / z));
            a = mov_shift(i).cdata;
            if mod(i, 200) == 0
                sprintf("%d frames of %d done\n", i, numofframes+1);
            end
            %imwrite(framei,strcat(fullfile(inputpath),i,'corrected','.tif'))
            %Write individual TIFF images after correction
            filepath = fullfile(pardir, strcat('drifted_', filename));
            if i == 1
                imwrite(a, strcat(filepath,'.tif'));
            else
                imwrite(a, strcat(filepath,'.tif'),'WriteMode','append');
            end
            %imwrite(framei,strcat(filename,'.tif'))
        end % i loop
        k = k + bigIter;
    end % j loop (bigIter blocks)
end


%NOTICE:
%For five (5) years from 01/24/2014, the United States Government is granted
%for itself and others acting on its behalf a paid-up, nonexclusive, irrevocable
%worldwide license in this data to reproduce, prepare derivative works, and perform
%publicly and display publicly, by or on behalf of the Government. There is provision
%for the possible extension of the term of this license. Subsequent to that period or
%any extension granted, the United States Government is granted for itself and others
%acting on its behalf a paid-up, nonexclusive, irrevocable worldwide license in this
%data to reproduce, prepare derivative works, distribute copies to the public, perform
%publicly and display publicly, and to permit others to do so. The specific term of the
%license can be identified by inquiry made to Sandia Corporation or DOE.
 
%NEITHER THE UNITED STATES GOVERNMENT, NOR THE UNITED STATES DEPARTMENT OF ENERGY,
%NOR SANDIA CORPORATION, NOR ANY OF THEIR EMPLOYEES, MAKES ANY WARRANTY, EXPRESS OR
%IMPLIED, OR ASSUMES ANY LEGAL RESPONSIBILITY FOR THE ACCURACY, COMPLETENESS, OR USEFULNESS
%OF ANY INFORMATION, APPARATUS, PRODUCT, OR PROCESS DISCLOSED, OR REPRESENTS THAT ITS USE
%WOULD NOT INFRINGE PRIVATELY OWNED RIGHTS.
 
%Any licensee of this software has the obligation and responsibility to abide by the
%applicable export control laws, regulations, and general prohibitions relating to the
%export of technical data. Failure to obtain an export control license or other authority
%from the Government may result in criminal liability under U.S. laws.
 
%(End of Notice)