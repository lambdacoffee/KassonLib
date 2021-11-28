function sneakPeek(VideoFilePath)
    
    %The first image in the video is read and displayed. A 3D array
    %(VideoMatrix) is created which will contain the data for all images in
    %the video.  VideoMatrix is pre-allocated with zeros to make the 
    %for loop faster.
    
    Options = formOptions();
    
    auto_dir = cd;
    cd ..
    scripts_dir = cd;
    cd(fullfile(scripts_dir, 'lipid_mixing_analysis_scripts', 'ExtractTracesFromVideo'));
    VideoInfo = imfinfo(VideoFilePath);
    NumFrames = length(VideoInfo);
    
        ImageWidth = VideoInfo.Width; %in pixels
        ImageHeight = VideoInfo.Height; %in pixels
        BitDepth = VideoInfo.BitDepth;
        VideoMatrix = zeros(ImageHeight, ImageWidth, NumFrames, 'uint16');
        
        %Create a logical matrix the same size as the video matrix.
        BWVideoMatrix = VideoMatrix > 0; 
        
        %Preallocate various vectors as well
        ThresholdToFindParticles = zeros(NumFrames,1);
        RoughBackground = zeros(NumFrames,1);
        
        %Set up figures
        [FigureHandles] = setupFigs();
        
    %This for loop populates the VideoMatrix with the data from each image
    %in the video.  The 1st two dimensions are the x,y of the image plane and the 3rd 
    %dimension is the frame number.
    for b = 1:NumFrames
        CurrentFrameImage = imread(VideoFilePath,b);
        VideoMatrix(:,:,b) = CurrentFrameImage;
        
        if b == Options.FrameNumToFindParticles + Options.FindFramesToAverage + 1
            %Display the finding image, including logical image. This is done 
            %before loading the rest of the frames, just in case the threshold 
            %needs to be changed and you don't want to have to wait for it 
            %to load up all the frames every time.
                FindingImage = mean(VideoMatrix(:,:,Options.FrameNumToFindParticles - Options.FindFramesToAverage...
                    :Options.FrameNumToFindParticles + Options.FindFramesToAverage),3);
                FindingImage = uint16(FindingImage);
                CurrentRoughBackground = mean(min(FindingImage));
                FindingThreshold = (CurrentRoughBackground + Options.Threshold)/2^BitDepth;
                BinaryFindingImage = im2bw(FindingImage, FindingThreshold);
                BinaryFindingImage = bwareaopen(BinaryFindingImage , Options.MinParticleSize, 8);

            %Plot the images
                set(0,'CurrentFigure',FigureHandles.ImageWindow);
                hold off
                imshow(FindingImage, [Options.MinImageShow, Options.MaxImageShow], 'InitialMagnification', 'fit','Border','tight');
                hold on

                set(0,'CurrentFigure',FigureHandles.BinaryImageWindow);
                imshow(BinaryFindingImage, 'InitialMagnification', 'fit','Border','tight');
                drawnow
        end
            
        
        % For each frame, the background intensity, average intensity, and 
        % integrated intensity are calculated. The threshold for each image 
        % is also calculated (this would be used if particles were being found 
        % or tracked in each image, which is currently not being done).
        RoughBackground(b) = mean(median(CurrentFrameImage));
        ThresholdToFindParticles(b) = (RoughBackground(b) + Options.Threshold)/2^BitDepth;
        
        %We apply the threshold to create a big logical matrix
        CurrThresh = ThresholdToFindParticles(b);
        BWVideoMatrix(:,:,b) = im2bw(CurrentFrameImage, CurrThresh);
        BWVideoMatrix(:,:,b) = bwareaopen(BWVideoMatrix(:,:,b), Options.MinParticleSize, 8);
        if b == Options.FrameNumToFindParticles + Options.FindFramesToAverage + 1
            break;
        end
    end
    cd(auto_dir);
end

function opts = formOptions()
    % Change parameters here!
    opts = struct();
    opts.FrameNumToFindParticles = 1790;
    opts.FindFramesToAverage = 3;
    opts.Threshold = 195;
    opts.MinParticleSize = 4;
    opts.MinImageShow = 70;
    opts.MaxImageShow = 900;
    opts.UseGaussianIntensity = 'y';
end

function [figs] = setupFigs()
    figs.BinaryImageWindow = figure(3);
    set(figs.BinaryImageWindow,'Position',[1 -50 450 341]);
    figs.ImageWindow = figure(1);
    set(figs.ImageWindow,'Position',[6   479   451   338]);
end
