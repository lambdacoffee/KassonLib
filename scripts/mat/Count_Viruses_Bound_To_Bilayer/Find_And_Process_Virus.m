function [BindingDataToSave, OtherDataToSave] =...
    Find_And_Process_Virus(StackFilePath,ThresholdInput,StackFilename, ...
    StackNum, DefaultPathname,Options)

%Parameters for Virus Goodness Test
    Options.MinSUVSize = 4;
    MaxEccentricity = 0.8; %0 = circle, 1 = line
    MaxVesSize = 100; %Number of pixels
    
    %The first image in the stack is read and displayed. A 3D array
    %(ImageStackMatrix) is created which will contain the data for all images in
    %the stack.  ImageStackMatrix is pre-allocated with zeros to make the next
    %for loop faster.
    StackInfo = imfinfo(StackFilePath);
    if isnan(Options.FrameNumberLimit)
        NumFrames = length(StackInfo);
    else
        NumFrames = Options.FrameNumberLimit;
    end
        ImageWidth = StackInfo.Width; %in pixels
        ImageHeight = StackInfo.Height;
        BitDepth = StackInfo.BitDepth;
        ImageStackMatrix = zeros(ImageWidth, ImageHeight, NumFrames, 'uint16');
        BWStackMatrix = ImageStackMatrix > 0; %Create a logical stack the same size as the image stack.
        
        %Preallocate threshold vectors as well
        ThresholdToFindViruses = zeros(NumFrames,1);
        RoughBackground = zeros(NumFrames,1);
        %Back_MedMed = zeros(NumFrames,1);
        
        %Set up figures
        [FigureHandles] = Setup_Figures(Options);
        
    %This for loop populates the ImageStackMatrix with the data from each image
    %in the stack.  The 1st two dimensions are the x,y of the image plane and the 3rd 
    %dimension is the frame number.
    for b = 1:NumFrames
        CurrentFrameImage = imread(StackFilePath,b);
        ImageStackMatrix(:,:,b) = CurrentFrameImage;
        
        if b == 1
%            Display first image
            set(0,'CurrentFigure',FigureHandles.ImageWindow);
            imshow(ImageStackMatrix(:,:,1), [Options.MinImageShow, Options.MaxImageShow], 'InitialMagnification', 'fit','Border','tight');
            drawnow
        end
        
        %We define the moving threshold which will be used to find Viruses
        %throughout the stack of images.
        RoughBackground(b) = mean(median(CurrentFrameImage));
        ThresholdToFindViruses(b) = (RoughBackground(b) + ThresholdInput)/2^BitDepth;
        
        %We apply the threshold to create a big logical matrix
        CurrThresh = ThresholdToFindViruses(b);
        BWStackMatrix(:,:,b) = im2bw(CurrentFrameImage, CurrThresh);
        BWStackMatrix(:,:,b) = bwareaopen(BWStackMatrix(:,:,b), Options.MinSUVSize, 8);
        
        if rem(b,20)==0
            set(0,'CurrentFigure',FigureHandles.CurrentTraceWindow);
            title(strcat('Loading Frame :', num2str(b),'/', num2str(NumFrames)));
            drawnow
        end
        
    end
    
    set(0,'CurrentFigure', FigureHandles.BackgroundTraceWindow);
    hold on
    plot(RoughBackground,'r-')
       
    NumFramesAnalyzed = 0;
    
    %Now we find all the viruses In each image
    if strcmp(Options.RemoveBleedthroughAreas,'y')
        FrameNumbersToAnalyze = 1:2:NumFrames;
    else
        FrameNumbersToAnalyze = 1:NumFrames;
    end
   
    for CurrFrameNum = FrameNumbersToAnalyze
        NumFramesAnalyzed = NumFramesAnalyzed + 1;
        
        CurrentImage = ImageStackMatrix(:,:,CurrFrameNum);
        BinaryCurrentImage = BWStackMatrix(:,:,CurrFrameNum);
        
        if strcmp(Options.IgnoreAreaNearBigParticles,'y')
                [CurrentImage,BinaryCurrentImage] = Remove_Area_Around_Big_Particles(Options,...
                    ImageWidth,ImageHeight,CurrentImage,BinaryCurrentImage,FigureHandles);
        end
        
        if strcmp(Options.RemoveBleedthroughAreas,'y')
            [CurrentImage,BinaryCurrentImage] = Remove_Bleedthrough_Areas(CurrFrameNum,CurrentImage,BinaryCurrentImage,...
                ImageStackMatrix,Options,FigureHandles,ImageHeight,ImageWidth);
        end
            NonzeroPixels = CurrentImage(CurrentImage ~= 0);
            NumberPixelsNotBlackedOut = length(NonzeroPixels);
            NumberMicronsNotBlackedOut = NumberPixelsNotBlackedOut*(0.16)^2;
        
        %All of the isolated regions left behind are "virus regions" and will
        %be analyzed.
            VirusComponentArray = bwconncomp(BinaryCurrentImage,8);

        %The properties associated with each virus in the binary image are
        %extracted.
            VirusProperties = regionprops(VirusComponentArray, CurrentImage, 'Centroid',...
                'Eccentricity', 'PixelValues', 'Area','PixelIdxList');
            NumberOfVirusesFound = length(VirusProperties);
            NumberGoodViruses = 0;
            NumberBadViruses = 0;
            
        %Plot the image
            set(0,'CurrentFigure',FigureHandles.ImageWindow);
            hold off
            imshow(CurrentImage, [Options.MinImageShow, Options.MaxImageShow], 'InitialMagnification', 'fit','Border','tight');
            hold on
            
            set(0,'CurrentFigure',FigureHandles.BinaryImageWindow);
            imshow(BinaryCurrentImage, 'InitialMagnification', 'fit','Border','tight');
            drawnow
        
        %Analyze each region
        for n = 1:NumberOfVirusesFound
            CurrentVirusProperties = VirusProperties(n);
            CurrVesX = round(VirusProperties(n).Centroid(1)); 
            CurrVesY = round(VirusProperties(n).Centroid(2));
                CurrentVirusProperties.Centroid = [CurrVesX, CurrVesY];
                
            set(0,'CurrentFigure',FigureHandles.ImageWindow);
            hold off
            title(strcat('Virus :', num2str(n),'/', num2str(NumberOfVirusesFound)));
            drawnow
            hold on
            
            %Apply many tests to see if Virus is good
            [IsVirusGood, CroppedImageProps, CurrentVirusBox, OffsetFrom2DFit, Noise,...
                DidFitWork, CroppedVesImageThresholded, SizeOfSquareAroundCurrVesicle,...
                CurrVesicleEccentricity, NewArea, ReasonVirusFailed] =...
                Simplified_Test_Goodness(CurrentImage,CurrentVirusProperties,BitDepth,...
                CurrThresh, Options.MinSUVSize, MaxEccentricity,ImageWidth, ImageHeight,MaxVesSize);
            
            if strcmp(IsVirusGood,'y')
                LineColor = 'g-';
                NumberGoodViruses = NumberGoodViruses + 1;
                
            elseif strcmp(IsVirusGood,'n')
                LineColor = 'r-';
                NumberBadViruses = NumberBadViruses + 1;
                disp(ReasonVirusFailed)    
            end
                                               
            %Plot a box around the Virus
                CVB = CurrentVirusBox;
                BoxToPlot = [CVB.Bottom,CVB.Left;CVB.Bottom,CVB.Right;CVB.Top,CVB.Right;CVB.Top,CVB.Left;CVB.Bottom,CVB.Left];

                set(0,'CurrentFigure',FigureHandles.ImageWindow);
                plot(BoxToPlot(:,2),BoxToPlot(:,1),LineColor)
                hold on
                drawnow
            
            %Now we grab the intensity of the current virus particle

                CurrentVirusArea = ImageStackMatrix(...
                    CurrentVirusBox.Top:CurrentVirusBox.Bottom,...
                    CurrentVirusBox.Left:CurrentVirusBox.Right,...
                    CurrFrameNum);

                CurrentRawIntensity = sum(sum((CurrentVirusArea)));

                CurrentIntensityBackSub = CurrentRawIntensity -...
                    RoughBackground(CurrFrameNum).*(CurrentVirusBox.Bottom - CurrentVirusBox.Top + 1)^2;                 

            %Save the data
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).RawIntensity = CurrentRawIntensity;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).IntensityBackSub = CurrentIntensityBackSub;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).Coordinates = VirusProperties(n).Centroid;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).Area = VirusProperties(n).Area;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).Eccentricity = VirusProperties(n).Eccentricity;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).FullFilePath = StackFilePath;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).StreamFilename = StackFilename;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).BoxAroundVirus = CurrentVirusBox;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).IsVirusGood = IsVirusGood;
                BindingDataToSave(NumFramesAnalyzed).VirusData(n).ReasonVirusFailed = ReasonVirusFailed;
        end
        BindingDataToSave(NumFramesAnalyzed).TotalVirusesBound = NumberOfVirusesFound;
        BindingDataToSave(NumFramesAnalyzed).NumberGoodViruses = NumberGoodViruses;
        BindingDataToSave(NumFramesAnalyzed).NumberBadViruses = NumberBadViruses
        BindingDataToSave(NumFramesAnalyzed).NumberPixelsNotBlackedOut = NumberPixelsNotBlackedOut;
        BindingDataToSave(NumFramesAnalyzed).NumberMicronsNotBlackOut = NumberMicronsNotBlackedOut;
        
    end

    OtherDataToSave.ThresholdsUsed = ThresholdToFindViruses;
    OtherDataToSave.RoughBackground = RoughBackground;
    
end