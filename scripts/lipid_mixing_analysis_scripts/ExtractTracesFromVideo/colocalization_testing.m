function [DataToSave, bg_sub, neg_sub, Counts] = colocalization_testing(prefix, suffix, pos_image, neg_image, test_threshold, Options)
    % compute colocalization info
    % in testing, used pos_image = 'p200s1000phtr3'
    % neg_image = 'p200s1000phm13'

    dat = imread(strcat(prefix, pos_image, suffix),1);
    negdat = imread(strcat(prefix, neg_image, suffix),1);
    ImageData = imfinfo(strcat(prefix, pos_image, suffix));
    ImageData = ImageData(1);
    bg_sub = double(dat - median(reshape(dat, 1, [])));
    figure; imshow(bwareaopen(im2bw(bg_sub./max(max(bg_sub)), (test_threshold)/max(max(bg_sub))), Options.MinParticleSize, 8));
    hold on;

    BinaryCurrImage = im2bw(bg_sub./max(max(bg_sub)), (test_threshold)/max(max(bg_sub)));BinaryCurrImage = bwareaopen(BinaryCurrImage , Options.MinParticleSize, 8);
    ParticleComponentArray = bwconncomp(BinaryCurrImage,8);
    ParticleProperties = regionprops(ParticleComponentArray, dat, 'Centroid',...
    'Eccentricity', 'PixelValues', 'Area','PixelIdxList', 'BoundingBox');
    NumberOfParticlesFound = length(ParticleProperties);
    CurrThresh = test_threshold/max(max(bg_sub));

    neg_sub = double(negdat - median(reshape(negdat,1,[])));
    neg_binary = im2bw(neg_sub./max(max(neg_sub)), (test_threshold-100)/max(max(neg_sub)));neg_binary = bwareaopen(neg_binary , Options.MinParticleSize, 8);


    % Initialize counters
    NumGoodParticles = 0;
    NumBadParticles = 0;
    NumNegParticles = 0;

    for n = 1:NumberOfParticlesFound
        CurrentParticleProperties = ParticleProperties(n);
        CurrVesX = round(ParticleProperties(n).Centroid(1));
        CurrVesY = round(ParticleProperties(n).Centroid(2));
        CurrentParticleProperties.Centroid = [CurrVesX, CurrVesY];
        %Apply many tests to see if Particle is good
        [IsParticleGood, ~, CurrentParticleBox, ~, ~, ~, ~, ~,...
            ~, ~, ReasonParticleFailed] =...
            Simplified_Test_Goodness(bg_sub,CurrentParticleProperties,ImageData.BitDepth,...
            CurrThresh, Options.MinParticleSize, Options.MaxEccentricity,ImageData.Width,...
            ImageData.Height,Options.MaxParticleSize,BinaryCurrImage,Options);
        if strcmp(IsParticleGood,'n')
            LineColor = 'r-';
            NumBadParticles = NumBadParticles + 1;
            if strcmp(Options.DisplayRejectionReasons,'y')
                disp(ReasonParticleFailed)
            end
        end
        if strcmp(IsParticleGood,'y')
            [IsParticleGood, ReasonParticleFailed] = ApplyNegScreen(...
                CurrentParticleProperties, BinaryCurrImage, neg_binary, ...
                ImageData.Width, ImageData.Height, IsParticleGood, ReasonParticleFailed, Options);
        end
        if strcmp(IsParticleGood,'y')
            LineColor = 'g-';
            NumGoodParticles = NumGoodParticles + 1;
        elseif strcmp(IsParticleGood,'s')
            % Removed with negative screen
            LineColor = 'm-';
            NumBadParticles = NumBadParticles + 1;
            NumNegParticles = NumNegParticles + 1;
            if strcmp(Options.DisplayRejectionReasons,'y')
               disp(ReasonParticleFailed)
            end
        end
        %Plot a box around the Particle. Green particles are "good" and 
        %red particles are "bad".
        CVB = CurrentParticleBox;
        BoxToPlot = [CVB.Bottom,CVB.Left;CVB.Bottom,CVB.Right;CVB.Top,CVB.Right;CVB.Top,CVB.Left;CVB.Bottom,CVB.Left];

        if strcmp(Options.DisplayAllFigures,'y')
            plot(BoxToPlot(:,2),BoxToPlot(:,1),LineColor)
            % could add text label here as text(CVB.Bottom, CVB.Right,
            % sprintf('%d', n));
            % but this wouldn't guarantee mapping to later
            hold on
            drawnow
        end

        DataToSave(n).Coordinates = ParticleProperties(n).Centroid;
        DataToSave(n).Eccentricity = ParticleProperties(n).Eccentricity;
        DataToSave(n).BoxAroundVirus = CurrentParticleBox;
        DataToSave(n).BBox = ParticleProperties(n).BoundingBox;
        DataToSave(n).IsVirusGood = IsParticleGood;
        DataToSave(n).ReasonVirusFailed = ReasonParticleFailed;
    end

    Counts.Good = NumGoodParticles;
    Counts.Bad = NumBadParticles;
    Counts.Neg = NumNegParticles;
end

