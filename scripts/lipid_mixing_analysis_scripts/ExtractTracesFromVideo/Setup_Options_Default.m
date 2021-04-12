                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                uare 
        % (so 5 means a 5x5 pixel ROI). The minimum size must always be 
        % specified. 'NaN' can be used to indicate no maximum size.

% ---------Image Visualization Options---------
    
    Options.MinImageShow = 90;
    Options.MaxImageShow = 900;
        % These determine the minimum and maximum intensity counts that will 
        % be used to set the contrast for the grayscale images that are displayed.
        % The minimum value will be displayed as black and the maximum value 
        % will be displayed as white.
    
% ---------Types Of Analysis Options---------
    Options.UseGaussianIntensity = 'n';
        % 'y' OR 'n'
        % Choose 'y' if you want to use a Gaussian fit to determine the local 
        % background around a viral particle and use that to determine the 
        % background subtracted intensity of the particle. Choose 'n' if 
        % you want to determine the background as an average across the entire 
        % image (i.e. the background value will be the same for all viral 
        % particles within a given frame). Default is 'n'.
    Options.GrabTotalIntensityOnly = 'n';
        % 'y' OR 'n'
        % Choose 'y' if you don't want to analyze each particle individually and 
        % only want to grab the intensity trace of the entire video. Not typical.
        
% ---------Workflow Options---------
    Options.AutoCreateLabels = 'n';
         % 'y' OR 'n'
        % Choose 'y' to automatically use information in the pathname and/or 
        % filename to create labels for the output data file and/or save folder. 
        % If so, you should modify Create_Save_Folder_And_Grab_Data_Labels.m so it 
        % extracts the information that you want.
    
    Options.UserGrabExampleTrace = 'n';
        % 'y' OR 'n'
        % Choose 'y' if you want to plot an example trace in a separate window. 
        % If you choose 'y', you should modify User_Grab_Example_Trace.m with 
        % the specific details of the trace that you want to plot and how you 
        % want to plot it.
        
    Options.FrameNumberLimit = NaN; 
        % Determines the number of frames which will be loaded and analyzed. 
        % Use 'NaN' to indicate no limit (i.e. all frames will be included).        
        % You would likely only use this option if you wanted to quickly 
        % assess how the program is running without having 
        % to wait for an entire video to load. Alternatively, you could 
        % use it to exclude frames at the end of the video from your analysis.
        

end