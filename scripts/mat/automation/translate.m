function translate(data_par_dir)
    mode = fileread('modality.txt');
    mode = str2double(mode);
    trace_data_subdir = fullfile(data_par_dir, 'TraceData');
    trace_analysis_subdir = fullfile(data_par_dir, 'TraceAnalysis');
    if mode
        trace_filenames = getTraceCell(trace_analysis_subdir);
        trace_text_subdir = fullfile(trace_analysis_subdir, 'TraceText');
        transcribeData(trace_filenames, trace_analysis_subdir, trace_text_subdir);
    else
        trace_filenames = getTraceCell(trace_data_subdir);
        collectData(trace_filenames, trace_data_subdir, trace_analysis_subdir);
    end
end

function trace_cell = getTraceCell(pardir)
    dir_struct = dir(pardir);
    file_arr = {dir_struct(3:end).name};
    isDir_arr = {dir_struct(3:end).isdir};
    count = 0;
    for i=1:length(isDir_arr)
        if ~isDir_arr{1, i}
            count = count + 1;
        end
    end
    trace_cell = cell(1, count);
    trace_ind = 1;
    for i=1:length(file_arr)
        if ~isDir_arr{1,i}
            trace_cell{trace_ind} = file_arr{1,i};
            trace_ind = trace_ind + 1;
        end
    end
end

function collectData(filenames, pardir, dst_dir)
    for i=1:length(filenames)
        disp(strcat("Translating: ", num2str(i), " of ", num2str(length(filenames))));
        src_data_filename = filenames{i};
        data_struct = load(fullfile(pardir, src_data_filename));
        [~, SrcDataFilenameSansExt] = fileparts(src_data_filename);
        txt_filepath = fullfile(dst_dir, 'TraceText', strcat(SrcDataFilenameSansExt, '.txt'));
        DataToSave = struct();
        DataToSave.CombinedAnalyzedTraceData = data_struct.VirusDataToSave(1);
        counter = 1;
        for j=1:length(data_struct.VirusDataToSave)
            if strcmp(data_struct.VirusDataToSave(j).IsVirusGood, 'n')
                continue;
            end
            DataToSave.CombinedAnalyzedTraceData(counter) = data_struct.VirusDataToSave(j);
            counter = counter + 1;
        end
        save(fullfile(dst_dir,strcat(SrcDataFilenameSansExt,'-Rvd','.mat')),'DataToSave');
        num_traces = length(DataToSave.CombinedAnalyzedTraceData);
        handleWriting(num_traces, txt_filepath, DataToSave);
    end
end

function transcribeData(filenames, pardir, dst_dir)
    for i=1:length(filenames)
        disp(strcat("Transcribing: ", num2str(i), " of ", num2str(length(filenames))));
        src_data_filename = filenames{i};
        data_struct = load(fullfile(pardir, src_data_filename));
        [~, SrcDataFilenameSansExt] = fileparts(src_data_filename);
        idx = strfind(SrcDataFilenameSansExt, '-Rvd');
        filename = SrcDataFilenameSansExt(1:idx-1);
        txt_filepath = fullfile(dst_dir, strcat(filename, '.txt'));
        num_traces = length(data_struct.DataToSave.CombinedAnalyzedTraceData);
        handleWriting(num_traces, txt_filepath, data_struct.DataToSave);
    end
end

function handleWriting(num_traces, text_filepath, data)
    y_vals_cell = cell(2, num_traces);
    for j=1:num_traces
        y_vals = data.CombinedAnalyzedTraceData(j).Trace_BackSub;
        y_vals_str = string(y_vals);
        y_vals_str = strjoin(y_vals_str, ',');
        y_vals_cell(1, j) = cellstr(strcat('@', num2str(j)));
        y_vals_cell(2, j) = cellstr(y_vals_str);
    end
    fid = fopen(text_filepath, 'W');
    fprintf(fid, '%s\n', string(y_vals_cell));
    fclose(fid);
end

