function Run_Me_To_Start()

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

    filepaths_text_filename = 'filepaths.txt';
    filepaths_text_filename = convertCharsToStrings(filepaths_text_filename);
    file_id = fileread(filepaths_text_filename);
    filepaths_cell_arr = strsplit(file_id);
    len = size(filepaths_cell_arr);

    analysis_script_path = filepaths_cell_arr{1};
    DefaultPathname = filepaths_cell_arr(2);
    SaveParentFolder = filepaths_cell_arr(3);
    vid_full_filepaths = filepaths_cell_arr(4:len(2)-1);
    len = size(vid_full_filepaths);
    StackFilenames = cell(1,len(2));
    StackParentPaths = cell(1,len(2));
    for i=1:len(2)
        full_filepath = convertCharsToStrings(char(vid_full_filepaths(1,i)));
        [parent_path, filename, ext] = fileparts(full_filepath);
        StackFilenames{1,i} = strcat(filename, ext);
        StackParentPaths{1,i} = parent_path;
    end
    NumberOfFiles = length(StackFilenames);
    correlations = getCorrelations(SaveParentFolder);

    close all

    % Analyze each video stream one by one
    for i = 1:NumberOfFiles
        
%         [Options] = Setup_Options(correlations(3,i));
% 
%         % Load the image files, chosen by the user
% 
%         % If selected, info is automatically grabbed from the data filenames and/or pathnames to make more 
%         % informative save folder directory and output analysis filenames. The save 
%         % folder is then created inside the parent directory.
%         if strcmp(Options.AutoCreateLabels,'y')
%             [DataFileLabel,SaveDataPathname] = Create_Save_Folder_And_Grab_Data_Labels(DefaultPathname,...
%             SaveParentFolder,Options);
%         else
%             % Otherwise, the label and save folder are defined as below.
%             SaveDataPathname = fullfile(char(SaveParentFolder), 'TraceData');
%             file_list = dir(SaveDataPathname);  % includes . & ..
%             data_num = length(file_list) - 1;
%             DataFileLabel = strcat("Datum-", int2str(data_num));
%             mkdir(SaveDataPathname);
%         end
% 
%         if NumberOfFiles > 1
%             CurrentFilename = StackFilenames{1,i};
%             CurrentParentPath = StackParentPaths{1,i};
%         else
%             CurrentFilename = StackFilenames;
%             CurrentParentPath = StackParentPaths;
%         end
% 
%         CurrStackFilePath = fullfile(CurrentParentPath,CurrentFilename);
% 
%         % Extract focus frame numbers, pH drop frame number, and frame to find
%         % the viruses from the data filename if it is there
%             if strcmp(Options.ExtractInputsFromFilename,'y')
%                 [Options] = Extract_Analysis_Inputs(Options,CurrentFilename);
%             end
%         % Print out options to commandline
%             diary_filepath = fullfile(char(SaveParentFolder), 'commandLog.txt');
%             diary(char(diary_filepath));
%             diary on
%             disp(Options);
% 
%         % Now we call the function to find the virus particles and extract
%         % their fluorescence intensity traces
%         [Results,VirusDataToSave, OtherDataToSave,Options] = ...
%             Find_And_Analyze_Particles(CurrStackFilePath,CurrentFilename, ...
%                 i, DefaultPathname,Options);
% 
%         % Analysis output file is saved to the save folder. All variables are saved.
%         save(fullfile(char(SaveDataPathname),char(strcat(DataFileLabel,"-Traces",".mat"))));
% 
%         % Results are displayed in the command prompt window
%         disp(Results);
%         cleanupFigures(SaveParentFolder);
    end

    disp("Extraction Complete.");
    disp("Analysis In Progress...");
    run(analysis_script_path);
    disp("Analysis Complete.");
    disp("Boxification In Progress...");
    handleBoxyVids(SaveParentFolder);
    disp("Boxification Complete.");
    
    disp("Execution Complete - Terminating Process.");
    disp("Thank you.  Come again.")
    diary off
    exit;

end

function cleanupFigures(data_dst_directory)
    subdir_names_arr = ["PotentialTraces", "Intensities", "BinaryMasks", "BackgroundTraces"];
    for i=1:length(subdir_names_arr)
        curr_subdir = fullfile(data_dst_directory, subdir_names_arr(i));
        handleFigure(i, curr_subdir);
    end
end

function handleFigure(fig_num, current_subdirectory)
    fig = figure(fig_num);
    file_list_struct = dir(current_subdirectory);
    data_num = length(file_list_struct) - 1;
    filename = strcat("Datum_", int2str(data_num));
    filepath = fullfile(char(current_subdirectory), char(filename));
    saveas(fig, filepath, 'tiffn');
    close(fig);
end

function file_list = getFileList(parent_directory)
    file_list_struct = dir(parent_directory);  % includes . & ..
    filename_cell_arr = struct2cell(file_list_struct);
    filename_cell_arr = filename_cell_arr(1,:,:);
    filename_cell_arr = filename_cell_arr(3:length(file_list_struct));
    len = length(filename_cell_arr);
    file_list = strings(1,len);
    for i=1:len
        file_list(1,i) = convertCharsToStrings(filename_cell_arr{1,i});
    end
end

function correlations = getCorrelations(parent_dst_dir)
    correlation_txt_filepath = fullfile(char(parent_dst_dir), 'info.txt');
    file_id = fileread(correlation_txt_filepath);
    temp_split_cell_arr = strsplit(file_id);
    temp_split_str_arr = strings(1,length(temp_split_cell_arr)-2);
    len = length(temp_split_str_arr);
    for i=1:len
        temp_split_str_arr(1,i) = temp_split_cell_arr{1,i+1};
    end
    header = temp_split_cell_arr{1,1};
    header = strsplit(header, ",");
    correlations = strings(length(header),length(temp_split_str_arr));
    for i=1:len
        temp = strsplit(temp_split_str_arr(i), ",");
        correlations(1,i) = temp(1,1);  % R1 is labels
        correlations(2,i) = temp(1,2);  % R2 is source vid filepaths
        correlations(3,i) = temp(1,3);  % R2 is source vid filepaths
        correlations(4,i) = temp(1,4);  % R2 is source vid filepaths
    end
end

function handleBoxyVids(parent_dst_dir)
    trace_analysis_dir = fullfile(char(parent_dst_dir), 'TraceAnalysis');
    trace_filename_list = getFileList(trace_analysis_dir);
    correlations = getCorrelations(parent_dst_dir);
    for i=1:length(trace_filename_list)
        curr_trace_analysis_filename = trace_filename_list(i);
        correlating_label = "";
        correlating_vid_filepath = "";
        for j=1:length(trace_filename_list)
            curr_label = correlations(1,j);
            if contains(curr_trace_analysis_filename, curr_label)
                % found the correlating filepath
                correlating_vid_filepath = correlations(2,j);
                correlating_label = curr_label;
            end
        end
        boxy_filename = strcat("BoxyVid-", correlating_label, ".tif");
        dst_filepath = fullfile(char(parent_dst_dir), 'BoxyVideos', char(boxy_filename));
        trace_filepath = fullfile(char(trace_analysis_dir), char(curr_trace_analysis_filename));
        overlayFusionBoxes(correlating_vid_filepath, trace_filepath, dst_filepath);
    end
end
