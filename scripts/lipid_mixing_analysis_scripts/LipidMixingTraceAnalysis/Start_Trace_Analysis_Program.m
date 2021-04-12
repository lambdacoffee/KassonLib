function Start_Trace_Analysis_Program()
% - - - - - - - - - - - - - - - - - - - - -

% Input:
% Start_Trace_Analysis_Program(), in this case the user navigates to the
%       .mat output file from the Extract Traces From Video program.
%   OR
% Start_Trace_Analysis_Program(DefaultPath), where DefaultPath is the directory to which 
%       the user will be automatically directed to find the 
%       .mat output file from the Extract Traces From Video program.

% Output:
% A .mat file is created which saves all of the variables in the current 
% workspace. This file is saved in a new folder created in the parent 
% directory where the input file came from. The information about the 
% waiting time for each lipid mixing event, as well as the designation 
% of each trace, is contained in the DataToSave.CombinedAnalyzedTraceData 
% structure, as defined in the Compile_Analyzed_Trace_Data.m file.

% Note: This program has been designed to process many sets of data sequentially,
% but it has only been tested with individual sets, so keep that 
% in mind if you choose to process many sets at once.

% By Bob Rawle, Kasson Lab, University of Virginia, 2016
% Published online in conjunction with:
% Rawle et al., Disentangling Viral Membrane Fusion from Receptor Binding 
% Using Synthetic DNA-Lipid Conjugates, Biophysical Journal (2016) 
% http://dx.doi.org/10.1016/j.bpj.2016.05.048
% - - - - - - - - - - - - - - - - - - - - -

    filepaths_text_filename = 'filepaths.txt';
    file_id = fileread(filepaths_text_filename);
    filepaths_cell_arr = strsplit(file_id);
    src_data_dir = filepaths_cell_arr{1};   % dir with trace data
    analysis_dst_dir = filepaths_cell_arr{2};   % DefaultPathname
    SaveParentFolder = fileparts(char(analysis_dst_dir));

    % Identify the paths to the data you wish to analyze
    %[DataFilenames,DefaultPathname] = Load_Data(varargin);
    
    % Determine how many files are being analyzed
    filename_list = getFileList(src_data_dir);
    correlations = getCorrelations(SaveParentFolder);
    RestartCount = [];
    CombinedAnalyzedTraceData = [];
    disp(' '); disp(' '); disp (' ');

    % Analyze files one by one
    for i = 1:length(filename_list)
        [Options] = Setup_Options(correlations(4,i));
        filename = filename_list(1,i);
        CurrDataFilePath = fullfile(src_data_dir, filename);

        % Call analysis function to analyze the data from the current set
        [AnalyzedTraceData,OtherDataToSave,StatsOfFailures,StatsOfDesignations] =...
        Analyze_Current_Data_Set(CurrDataFilePath,Options);
        
        [~,name,~] = fileparts(filename);
        label = strcat(Options.Label, "_", name);
        Save_Data_At_Each_Step(AnalyzedTraceData,OtherDataToSave,analysis_dst_dir,label,Options)

        
        %To combine the data from dif files, we have to deal with empty structures,
        %which can create problems.  So we deal with it and then
        %combine the current data with the previous iterations
        [CombinedAnalyzedTraceData,RestartCount]= ...
        Deal_With_Empty_Recorded_Data(i,AnalyzedTraceData,CombinedAnalyzedTraceData,RestartCount);

        % Print out results/statistics to commandline
        disp(strcat('-----------------File_', num2str(i),'_of_',num2str(length(filename_list)),'-----------------'))
        disp(' ')
        disp(strcat('Filename: ', filename))
        disp(StatsOfFailures);
        disp(StatsOfDesignations);
        disp('---------------------------------------------')
        disp(' ')
        disp(' ')
        
        cleanupFigures();
    end    
end

function Save_Data_At_Each_Step(AnalyzedTraceData,OtherDataToSave,DefaultPathname,Label,Options)

    DataToSave.OtherDataToSave = OtherDataToSave;

    if strcmp(Options.BobStyleSave,'y')
        IndexofSlash = find(DefaultPathname == '/');
        SaveDataFolder = DefaultPathname(1:IndexofSlash(end-1));
        SaveDataFolder = fullfile(SaveDataFolder, 'TraceAnalysis');
    else
        SaveDataFolder = DefaultPathname;
    end

    if exist(SaveDataFolder,'dir') == 0
        mkdir(SaveDataFolder);
    end

    if ~isempty(AnalyzedTraceData)
        DataToSave.CombinedAnalyzedTraceData = AnalyzedTraceData;
        save(fullfile(SaveDataFolder,strcat(Label,'.mat')),'DataToSave');
    end
end

function [CombinedAnalyzedTraceData,RestartCount]= ...
                Deal_With_Empty_Recorded_Data(i,AnalyzedTraceData,CombinedAnalyzedTraceData,RestartCount)

    %Compile the data which will be saved (there are lots of
    %complicated if statements here just to deal with the times
    %that there doesn't happen to be any events recorded in a given file).
    if i == 1
        if ~isempty(AnalyzedTraceData)
            CombinedAnalyzedTraceData = AnalyzedTraceData; %This is a structure
            RestartCount = 'n';
        else
            RestartCount = 'y';
        end
        
    else
        if RestartCount == 'y'
            if ~isempty(AnalyzedTraceData)
                CombinedAnalyzedTraceData = AnalyzedTraceData; %This is a structure
                RestartCount = 'n';
            else
                RestartCount = 'y';
            end
        elseif ~isempty(AnalyzedTraceData)
            StartIdx = length(CombinedAnalyzedTraceData) + 1;
            EndIdx = StartIdx + length(AnalyzedTraceData)-1;
            CombinedAnalyzedTraceData(StartIdx:EndIdx) = AnalyzedTraceData;
        end
    end
end

function cleanupFigures()
    fig_nums_ordered = [23,24,1];
    for i=1:length(fig_nums_ordered)
        fig = figure(fig_nums_ordered(i));
        close(fig);
    end
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
    correlation_txt_filepath = fullfile(parent_dst_dir, "info.txt");
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
