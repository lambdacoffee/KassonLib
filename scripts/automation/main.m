function main()

% - - - - - - - - - - - - - - - - - - - - -

% Input:
% Run_Me_To_Start(), in this case the user navigates to the image video
%       stacks and also chooses the parent folder where the output analysis files will be saved
%   OR
% Run_Me_To_Start(DefaultPath), where DefaultPath is the directory to which 
%       the user will be automatically directed to find the image video
%       stacks. After choosing the video stacks, the user then chooses the 
%       parent folder where the output analysis files will be saved.
%   OR
% Run_Me_To_Start(DefaultPath,SavePath), where DefaultPath is as above, and 
%       SavePath is the parent folder where the output analysis files will be saved

% Output:
% A .mat file is created which saves all of the variables in the current 
% workspace. This file will be the input for the Lipid Mixing Trace Analysis program. Within 
% this file, the intensity traces for each viral particle which has been 
% found, together with additional data for each virus, will be in the 
% VirusDataToSave structure, as defined in Find_And_Analyze_Particles.m

% Note: This program has not been designed to process many videos sequentially,
% but it has been tested with individual video streams, so keep that 
% in mind if you choose to process many videos at once.

% By Bob Rawle, Kasson Lab, University of Virginia, 2016
% Published online in conjunction with:
% Rawle et al., Disentangling Viral Membrane Fusion from Receptor Binding 
% Using Synthetic DNA-Lipid Conjugates, Biophysical Journal (2016) 
% http://dx.doi.org/10.1016/j.bpj.2016.05.048
% - - - - - - - - - - - - - - - - - - - - -
    
    filepaths_text_filename = 'filepaths_EXTRACTION.txt';
    file_id = fileread(filepaths_text_filename);
    filepaths_cell_arr = strsplit(file_id);
    len = size(filepaths_cell_arr);

    analysis_script_path = filepaths_cell_arr{1};
    DefaultPathname = filepaths_cell_arr{2};
    SaveParentFolder = filepaths_cell_arr{3};
    ij_path = filepaths_cell_arr(4);
    kasson_lib_directory = filepaths_cell_arr(5);
    vid_full_filepaths = filepaths_cell_arr(6:len(2)-1);
    len = size(vid_full_filepaths);
    StackFilenames = cell(1,len(2));
    StackParentPaths = cell(1,len(2));
    for i=1:len(2)
        full_filepath = char(vid_full_filepaths(1,i));
        [parent_path, filename, ext] = fileparts(full_filepath);
        StackFilenames{1,i} = strcat(filename, ext);
        StackParentPaths{1,i} = parent_path;
    end
    NumberOfFiles = length(StackFilenames);
    correlations = getCorrelations(SaveParentFolder);
    
    mode = fileread('modality.txt');
    mode = str2double(mode);

    close all
    auto_dir = cd;

    % Analyze each video stream one by one
    for i = 1:NumberOfFiles
        
        cd(auto_dir);
        [Options] = Setup_Options(correlations(3,i));
        cd ..
        cd(fullfile(cd, 'lipid_mixing_analysis_scripts', 'ExtractTracesFromVideo'));
        
        % Load the image files, chosen by the user

        % If selected, info is automatically grabbed from the data filenames and/or pathnames to make more 
        % informative save folder directory and output analysis filenames. The save 
        % folder is then created inside the parent directory.
        if strcmp(Options.AutoCreateLabels,'y')
            [DataFileLabel,SaveDataPathname] = Create_Save_Folder_And_Grab_Data_Labels(DefaultPathname,...
            SaveParentFolder,Options);
        else
            % Otherwise, the label and save folder are defined as below.
            SaveDataPathname = fullfile(char(SaveParentFolder), 'TraceData');
            file_list = dir(SaveDataPathname);  % includes . & ..
            data_num = length(file_list) - 1;
            if mode
                DataFileLabel = strcat("Datum-", int2str(data_num));
                Options.Label = DataFileLabel;
            else
                label = Options.Label;
                DataFileLabel = strcat(label, "_Datum-", int2str(data_num));
            end
        end

        if NumberOfFiles > 1
            CurrentFilename = StackFilenames{1,i};
            CurrentParentPath = StackParentPaths{1,i};
        else
            CurrentFilename = StackFilenames;
            CurrentParentPath = StackParentPaths;
        end

        CurrStackFilePath = fullfile(CurrentParentPath,CurrentFilename);

        % Extract focus frame numbers, pH drop frame number, and frame to find
        % the viruses from the data filename if it is there
            if strcmp(Options.ExtractInputsFromFilename,'y')
                [Options] = Extract_Analysis_Inputs(Options,CurrentFilename);
            end
        % Print out options to command line
            diary_filepath = fullfile(char(SaveParentFolder), 'commandLog.txt');
            diary(char(diary_filepath));
            diary on
            disp(Options);

        % Now we call the function to find the virus particles and extract
        % their fluorescence intensity traces
        [Results,VirusDataToSave, OtherDataToSave,Options] = ...
            Find_And_Analyze_Particles(CurrStackFilePath,CurrentFilename, ...
                i, DefaultPathname,Options);
        
        if ~mode
            for j=1:length(VirusDataToSave)
                VirusDataToSave(j).TimeInterval = Options.TimeInterval;
                VirusDataToSave(j).Designation = 'No Fusion';
            end
        end
        
        % Analysis output file is saved to the save folder. All variables are saved.
        save(fullfile(char(SaveDataPathname),char(strcat(DataFileLabel,"-Traces",".mat"))));

        % Results are displayed in the command prompt window
        disp(Results);
        cleanupFigures(SaveParentFolder);
    end

    disp("Extraction Complete.");
    cd(auto_dir);
    if mode
        disp("Analysis In Progress...");
        run(analysis_script_path);
        cd(auto_dir);
    end
    disp("Translation in progress...")
    cd(auto_dir);
    translate(SaveParentFolder);
    disp("Boxification in progress...");
    trace_analysis_dir = fullfile(char(SaveParentFolder), 'TraceAnalysis');
    handleBoxification(SaveParentFolder, trace_analysis_dir);

    info_filepath = fullfile(char(SaveParentFolder), 'info.txt');
    boxification_macro_path = fullfile(kasson_lib_directory, ...
        'LipidViralAnalysis', 'bin', 'boxification.ijm');
    boxy_arg = strcat(info_filepath, ",", "1");
    if ispc
        box_command = strcat(ij_path, " -macro ", ...
            boxification_macro_path, " ", boxy_arg);
        py_command = strcat("python -m fusion_review ", SaveParentFolder);
        system(box_command);
        system(strcat("start cmd.exe /c ", py_command));
    elseif isunix
        py_command = strcat("python3 -m fusion_review ", SaveParentFolder);
        system(py_command);
    end
    disp("Analysis Complete - Terminating Process.");
    disp("Thank you.  Come again.")
    diary off
    exit;
end

function cleanupFigures(data_dst_directory)
    subdir_names_arr = ["PotentialTraces", "Intensities", "BinaryMasks", "BackgroundTraces"];
    for i=1:length(subdir_names_arr)
        curr_subdir = fullfile(char(data_dst_directory), char(subdir_names_arr(i)));
        handleFigure(i, curr_subdir);
    end
end

function handleFigure(fig_num, current_subdirectory)
    fig = figure(fig_num);
    file_list_struct = dir(current_subdirectory);
    data_num = length(file_list_struct) - 1;
    filename = strcat("Datum-", int2str(data_num));
    filepath = fullfile(char(current_subdirectory), char(filename));
    saveas(fig, filepath, 'fig');
    close(fig);
end
