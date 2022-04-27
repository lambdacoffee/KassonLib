function runExtractionProcess(GlobalVars)
    % Analyze each video stream one by one
    for i = 1:GlobalVars.NumberOfFiles
        cd(GlobalVars.AutoDir);
        [Options] = Setup_Options(GlobalVars.infoCorrelations{3,i});
        cd ..
        cd(fullfile(cd, 'lipid_mixing_analysis_scripts', 'ExtractTracesFromVideo'));
        
        % Load the image files, chosen by the user

        % If selected, info is automatically grabbed from the data filenames and/or pathnames to make more 
        % informative save folder directory and output analysis filenames. The save 
        % folder is then created inside the parent directory.
        if strcmp(Options.AutoCreateLabels,'y')
            [DataFileLabel,GlobalVars.SaveDataPathname] = ...
                Create_Save_Folder_And_Grab_Data_Labels(GlobalVars.DefaultPathname,...
            GlobalVars.SaveParentFolder,Options);
        else
            % Otherwise, the label and save folder are defined as below.
            GlobalVars.SaveDataPathname = ...
                fullfile(char(GlobalVars.SaveParentFolder), 'TraceData');
            datum_tag = char(GlobalVars.infoCorrelations(1,i));
            datum_num = str2num(datum_tag(strfind(datum_tag, '-')+1:end));
            if GlobalVars.Mode
                DataFileLabel = strcat("Datum-", int2str(datum_num));
                Options.Label = DataFileLabel;
            else
                label = Options.Label;
                DataFileLabel = strcat(label, "_Datum-", int2str(datum_num));
            end
        end

        if GlobalVars.NumberOfFiles > 1
            CurrentFilename = GlobalVars.StackFilenames{1,i};
            CurrentParentPath = GlobalVars.StackParentPaths{1,i};
        else
            CurrentFilename = GlobalVars.StackFilenames;
            CurrentParentPath = GlobalVars.StackParentPaths;
        end

        CurrStackFilePath = fullfile(CurrentParentPath,CurrentFilename);

        % Extract focus frame numbers, pH drop frame number, and frame to find
        % the viruses from the data filename if it is there
            if strcmp(Options.ExtractInputsFromFilename,'y')
                [Options] = Extract_Analysis_Inputs(Options,CurrentFilename);
            end
        % Print out options to command line
            diary_filepath = fullfile(...
                char(GlobalVars.SaveParentFolder), 'commandLog.txt');
            diary(char(diary_filepath));
            diary on
            disp(Options);

        % Now we call the function to find the virus particles and extract
        % their fluorescence intensity traces
        [Results,VirusDataToSave, OtherDataToSave,Options] = ...
            Find_And_Analyze_Particles(CurrStackFilePath,CurrentFilename, ...
                i, GlobalVars.DefaultPathname,Options);
        
        if GlobalVars.Mode ~= 0
            for j=1:length(VirusDataToSave)
                VirusDataToSave(j).TimeInterval = Options.TimeInterval;
                VirusDataToSave(j).Designation = 'No Fusion';
            end
        end
        for j=1:length(VirusDataToSave)
            VirusDataToSave(j).isExclusion = 0;
        end
        
        % Analysis output file is saved to the save folder. All variables are saved.
        save(fullfile(...
            char(GlobalVars.SaveDataPathname),...
            char(strcat(DataFileLabel,"-Traces",".mat"))));

        % Results are displayed in the command prompt window
        disp(Results);
        cleanupFigures(GlobalVars.SaveParentFolder, datum_num);
    end
end

function cleanupFigures(data_dst_directory, datum_num)
    subdir_names_arr = ["PotentialTraces", "Intensities", "BinaryMasks", "BackgroundTraces"];
    for i=1:length(subdir_names_arr)
        curr_subdir = fullfile(char(data_dst_directory), char(subdir_names_arr(i)));
        handleFigure(i, curr_subdir, datum_num);
    end
end

function handleFigure(fig_num, current_subdirectory, datum_num)
    fig = figure(fig_num);
    filename = strcat("Datum-", int2str(datum_num));
    filepath = fullfile(char(current_subdirectory), char(filename));
    saveas(fig, filepath, 'fig');
    close(fig);
end
