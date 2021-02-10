function [Options] = Setup_Options()

    Options.DataFileLabel = 'TestLabel';
        % This is the label for the output .mat file.

    Options.Threshold = 90; 
        % This is the number of counts above background which will be used
        % to detect virus particles. You will need to optimize this number 
        % for each set of imaging conditions and/or each data set. An optimal 
        % threshold value has been reached when you are able to see that the
        % program is accurately finding the particles in each image. To avoid
        % bias introduced by the optimization process, you should make sure 
        % that changing the optimal threshold value somewhat doesn't 
        % significantly affect your data. Assuming similar particle 
        % densities/intensities between data sets, and that the same imaging 
        % conditions are used, you shouldn't need to change the threshold 
        % value much if at all between data sets.
    
    Options.FrameNumberLimit = NaN; 
        % Determines the number of frames which will be loaded and analyzed. 
        % Use 'NaN' to indicate no limit (i.e. all frames will be included).        
        % You would likely only use this option if you wanted to quickly 
        % assess how the program is running without having 
        % to wait for an entire video to load. Alternatively, you could 
        % use it to exclude frames at the end of the video from your analysis.

   
    Options.MinImageShow = 100;
    Options.MaxImageShow = 500;    
        % These determine the minimum and maximum intensity counts that will 
        % be used to set the contrast for the grayscale images that are displayed.
        % The minimum value will be displayed as black and the maximum value 
        % will be displayed as white.
        
    Options.IgnoreAreaNearBigParticles = 'y';
        % 'y' OR 'n'
        % Choose 'y' if you want to ignore the region around bright particles 
        % because the noise nearby from those particles is being incorrectly 
        % identified as other particles. If you choose 'y', then you need 
        % to specify what size is considered "big" below. You will also need 
        % to scale your data to account for the regions which have been ignored, 
        % as this can artificially skew your results lower than they should be.
    Options.MinAreaBig = 150;
        % The number of pixels above threshold for a particle to be considered 
        % "too big", in which case the region around that particle will be 
        % ignored if that option is chosen above.
        
        
    Options.RemoveBleedthroughAreas = 'y';
        % Choose 'y' if you'd like to remove the contribution from bright 
        % debris in the bilayer (un-ruptured vesicles, etc.) which bleeds through 
        % into the viral particle channel and is incorrectly identified as 
        % viral particle. The contribution from these spots should be 
        % minimal, but this is a way to remove them entirely. If you choose 'y', 
        % then your data should be formatted as viral image followed by bilayer image.

end