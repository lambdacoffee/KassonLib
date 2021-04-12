function Start_User_Review_MODIFIED(SaveParentFolder)

close all

% Identify the path to the data you wish to analyze
    % [DataFilename,DefaultPathname] = Load_Data(varargin);
        % Nested function

    trace_analysis_subdir = fullfile(SaveParentFolder, 'TraceAnalysis');
    trace_drawings_subdir = fullfile(trace_analysis_subdir, 'TraceDrawings');
    analysisRXD_subdir = fullfile(trace_analysis_subdir, 'AnalysisRXD');
    dir_struct = dir(analysisRXD_subdir);
    file_arr = {dir_struct(3:end).name};
    
    for f=1:length(file_arr)
        DefaultPathname = analysisRXD_subdir;
        DataFilename = file_arr{f};
        DataFilePath = fullfile(DefaultPathname, DataFilename);
        [~, filenameWithoutExt, ~] = fileparts(DataFilePath);
        drawing_filepath = fullfile(trace_drawings_subdir, [filenameWithoutExt,'.tif']);
    
        % Setup options
            [DataCounters,Options] = Setup_User_Review_Options_Default();

        % Extract data that we will need
            InputData = load(DataFilePath);
            %InputData = InputData.dat;      % adapting to Kasson edited struct - rescoring
            DataToSave = InputData.DataToSave;
            UniversalData = InputData.DataToSave.OtherDataToSave.UniversalData;
            PreviousAnalysisData = InputData.DataToSave.CombinedAnalyzedTraceData;
            NumTraces = length(PreviousAnalysisData);

        % Define variables we will need
            CorrectedAnalysisData = PreviousAnalysisData;
            NumTracesToReview = NumTraces - Options.StartingTraceNumber - 1;
            NumReviewRounds = ceil(NumTracesToReview/Options.TotalNumPlots);
            TraceCounter = Options.StartingTraceNumber;
            ErrorCounter = 0;

        % Create master window with subplots
            [FigureHandles] = Create_Master_Window(Options);

        % Review plots round by round
            for b = 1:NumReviewRounds

                disp(strcat('Round-', num2str(b),'-of-', num2str(NumReviewRounds)))

                if b < NumReviewRounds
                    CurrentTraceRange = TraceCounter:TraceCounter + Options.TotalNumPlots - 1;
                    TraceCounter = max(CurrentTraceRange)+1;
                else
                    CurrentTraceRange = TraceCounter:NumTraces;
                end

                % Load and plot the current round
                PlotCounter = 1;
                for i = CurrentTraceRange

                    CurrentTraceNumber = i;
                    CurrentVirusData = PreviousAnalysisData(i);
                    CurrentTraceBackSub = CurrentVirusData.Trace_BackSub;

                    % Correct focus problems
                    %[CurrentTraceBackSub] = Correct_Focus_Problems(CurrentTraceBackSub,UniversalData);
                    if PlotCounter > 18
                        break;
                    end
                    [FigureHandles] = Plot_Current_Trace(FigureHandles,CurrentVirusData,UniversalData,...
                        CurrentTraceBackSub,PlotCounter,CurrentTraceNumber);
                    PlotCounter = PlotCounter +1;
                end

                fig = figure(1);
                frame = getframe(fig);
                imwrite(frame.cdata, drawing_filepath, 'WriteMode', 'append')

                DataCounters.CurrentErrorCount = ErrorCounter;
                DataCounters.CurrentTraceNumber = CurrentTraceNumber;
                DataCounters.CurrentErrorRate = ErrorCounter/CurrentTraceNumber;

                DataCounters

                if  strcmp(Options.SaveAtEachStep,'y')
                    DataToSave.DataCounters = DataCounters;
                    %Save_Data_At_Each_Step(DataFilename,DefaultPathname,DataToSave,CorrectedAnalysisData,Options)
                end
            end

            if ~strcmp(Options.SaveAtEachStep,'y')
                DataToSave.DataCounters = DataCounters;
                %Save_Data_At_Each_Step(DataFilename,DefaultPathname,DataToSave,CorrectedAnalysisData,Options)
            end

            close all;
    end
	disp('Thank You. Come Again.')
end

function [DataFilenames,DefaultPathname] = Load_Data(varargin)
    if length(varargin) == 1
        [DataFilenames, DefaultPathname] = uigetfile('*.mat','Select .mat files to be analyzed',...
            char(varargin{1}),'Multiselect', 'on');
    else
        [DataFilenames, DefaultPathname] = uigetfile('*.mat','Select .mat files to be analyzed', 'Multiselect', 'on');
    end
end

function Save_Data_At_Each_Step(DataFilename,DefaultPathname,DataToSave,CorrectedAnalysisData,Options)

SaveDataFolder = DefaultPathname;

SaveDataFolder = strcat(SaveDataFolder,'/AnalysisReviewed/');
if exist(SaveDataFolder,'dir') == 0
    mkdir(SaveDataFolder);
end

DataFilenameWOExt = DataFilename(1:end-4);
    if ~isempty(CorrectedAnalysisData)
        DataToSave.ReviewOptions = Options;
        DataToSave.CombinedAnalyzedTraceData = CorrectedAnalysisData;
        save(strcat(SaveDataFolder,DataFilenameWOExt,Options.Label,'.mat'),'DataToSave');
    end
end