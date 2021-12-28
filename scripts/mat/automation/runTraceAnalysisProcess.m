function runTraceAnalysisProcess(GlobalVars)
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

    % dir with trace data
    src_data_dir = fullfile(GlobalVars.SaveParentFolder, 'TraceData');
    % DefaultPathname
    analysis_dst_dir = fullfile(GlobalVars.SaveParentFolder, 'TraceAnalysis');

    % Determine how many files are being analyzed
    filename_list = getFileList(src_data_dir);
    RestartCount = [];
    CombinedAnalyzedTraceData = [];
    disp(' '); disp(' '); disp (' ');

    % Analyze files one by one
    for i = 1:length(filename_list)
        cd(GlobalVars.AutoDir);
        [Options] = Setup_Options(GlobalVars.infoCorrelations{4,i});
        filename = char(filename_list(1,i));
        CurrDataFilePath = fullfile(char(src_data_dir), filename);
        cd ..
        cd(fullfile(cd, 'lipid_mixing_analysis_scripts', 'LipidMixingTraceAnalysis'));
        
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
        
        close all
    end    
end

function Save_Data_At_Each_Step(AnalyzedTraceData,OtherDataToSave,DefaultPathname,Label,Options)

    DataToSave.OtherDataToSave = OtherDataToSave;

    if strcmp(Options.BobStyleSave,'y')
        IndexofSlash = find(DefaultPathname == '/');
        SaveDataFolder = DefaultPathname(1:IndexofSlash(end-1));
        SaveDataFolder = fullfile(char(SaveDataFolder), 'TraceAnalysis');
    else
        SaveDataFolder = DefaultPathname;
    end

    if exist(SaveDataFolder,'dir') == 0
        mkdir(SaveDataFolder);
    end

    if ~isempty(AnalyzedTraceData)
        DataToSave.CombinedAnalyzedTraceData = AnalyzedTraceData;
        for i=1:length(DataToSave.CombinedAnalyzedTraceData)
            DataToSave.CombinedAnalyzedTraceData(i).isExclusion = 0;
        end
        save(fullfile(char(SaveDataFolder), char(strcat(Label,'-Rvd','.mat'))),'DataToSave');
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
