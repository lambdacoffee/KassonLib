function DataToSave = Rescore_Traces_Modified(DoNormalize)
% Rescore fusion traces
[SrcDataFilename, SrcDataParDir] = uigetfile();

cd ..
scripts_dir = cd;
LMTA_subdir = fullfile(scripts_dir, 'lipid_mixing_analysis_scripts', 'LipidMixingTraceAnalysis');
URT_subdir = fullfile(scripts_dir, 'lipid_mixing_analysis_scripts', 'ExtractTracesFromVideo', 'User_Review_Traces');
addpath(LMTA_subdir);
addpath(URT_subdir);

src_filepath = fullfile(SrcDataParDir, SrcDataFilename);
dat = load(src_filepath);
ntraces = length(dat.DataToSave.CombinedAnalyzedTraceData);
fig_opt.NumPlotsX = 1;
fig_opt.NumPlotsY = 1;
fig = Create_Master_Window(fig_opt);
method = 'b';  % binding and fusion; set to 's' if want to measure slow fusion
if nargin <= 1
    DoNormalize = 1;
end
DoNormalize = 0;
% find the particle that varies the least and use it to normalize
% option 1: min(std).  option 2: min(ssd from start)
% do batch normalization
batchsize = 30;
batchctr = 1;
% pre-allocate trace_std
trace_std(1:batchsize) = 0;
i=1;
[~, filenameWithoutExt, ext] = fileparts(src_filepath);
if contains(filenameWithoutExt, strcat('_mod-', method, '-rxd'))
    dst_filename = [filenameWithoutExt, ext];
    SaveDataPath = fullfile(SrcDataParDir, dst_filename);
else
    dst_filename = strcat(filenameWithoutExt, "_mod-", method, "-rxd", ext);
    SaveDataPath = fullfile(SrcDataParDir, 'AnalysisRXD', dst_filename);
end

skip_flag = 's';
quit_flag = 'q';
seek_flag = 'k';
previous_flag = 'p';
resume_flag = 'x';

DataToSave = dat.DataToSave;
while i <= ntraces
    % normalization
    if i > ntraces
        break;
    end
    fprintf('Current Trace: %d out of %d\n', i, ntraces);
    if (mod(i, batchsize) == 1) && (i < ntraces - batchsize + 1)
        % new batch of traces for normalization
        for j=0:batchsize-1
            trace_std(j+1) = std(DataToSave.CombinedAnalyzedTraceData(j+batchctr).Trace);
        end
        [~, minidx] = min(trace_std);
        min_trace = DataToSave.CombinedAnalyzedTraceData(minidx+batchctr-1).Trace;
        batchctr = batchctr + batchsize;
    end
    % review each trace
    cur_trace = DataToSave.CombinedAnalyzedTraceData(i);
    if DoNormalize
        cur_trace.Trace_BackSub = cur_trace.Trace ./ min_trace;
    end
    Plot_Trace_For_Rescore(fig, cur_trace, DataToSave.OtherDataToSave.UniversalData, ...
        cur_trace.Trace_BackSub, 1, 1);
    save(SaveDataPath, 'DataToSave', '-mat');
    msg = strcat('Enter corresponding flag for function:\n', ...
        'f -fusion, a -anomalous, n -no fusion, ',...
        previous_flag, ' -previous, ',...
        skip_flag,' -skip, ',...
        quit_flag, ' -quit, ',...
        seek_flag, ' -seek, ',...
        resume_flag, ' -resume \n');
    fuse_type = input(msg,'s');
    if fuse_type == 'f'
        [x, y] = ginput(2);
        cur_trace.Designation = 'Fuse';
        if method == 's'  % slow fusion measurement
            cur_trace.FusionData.FusionJump = y(2) - y(1);
            cur_trace.FusionData.FusionInterval = (x(2) - x(1)) * cur_trace.FusionData.TimeInterval;
            cur_trace.FusionData.pHtoFusionTime = (x(1) - cur_trace.FusionData.pHDropFrameNumber) ...
                * cur_trace.FusionData.TimeInterval;
            cur_trace.FusionData.FuseFrameNumbers = round(x(1));
            cur_trace.FusionData.pHtoFusionNumFrames = round(x(1)) - cur_trace.FusionData.pHDropFrameNumber;
        else  % measure binding and fusion
            cur_trace.FusionData.FusionJump = y(2) - y(1);
            cur_trace.FusionData.FusionInterval = (x(2) - x(1)) * cur_trace.FusionData.TimeInterval;
            cur_trace.FusionData.pHtoFusionTime = (x(2) - x(1)) * cur_trace.FusionData.TimeInterval;
            cur_trace.FusionData.FuseFrameNumbers = round(x(2));
        end
        fprintf(1, 'Fusion started %f\n', x(1));
        cur_trace.ChangedByUser = 'Reviewed By User';
        cur_trace.FusionData.Designation = '1 Fuse';
    elseif fuse_type == 'n'
        cur_trace.Designation = 'No Fusion';
        cur_trace.FusionData.Designation = 'No Fusion';
        cur_trace.ChangedByUser = 'Reviewed By User';
    elseif fuse_type == 'a'
        cur_trace.Designation = 'Anomalous';
    elseif fuse_type == previous_flag
        if i>1
            i = i-1;
        end
        continue;
    elseif fuse_type == quit_flag
        break;
    elseif fuse_type == seek_flag
        trace_num = input('Enter trace number to resume to: ', 's');
        i = str2double(trace_num);
        continue;
    elseif fuse_type == skip_flag
        i = i+1;
        continue
    elseif fuse_type == resume_flag
        for j=1:ntraces
            scanning_trace = DataToSave.CombinedAnalyzedTraceData(j).ChangedByUser;
            if ~strcmp(scanning_trace, 'Reviewed By User')
                i = j;
                break;
            end
            if j == ntraces
                j = j+1;
            end
        end
        if j <= ntraces
            continue;
        else
            disp('It seems like everything has been reviewed!');
        end
    else
        disp('Unknown input!');
        continue;
    end
    DataToSave.CombinedAnalyzedTraceData(i) = cur_trace;
    i = i+1;
end
% save
%save(sprintf('%s%s.mat', filename(1:end-4), 'rescored'), 'dat');
save(SaveDataPath, 'DataToSave');
