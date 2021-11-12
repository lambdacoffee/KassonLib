function translate(data_par_dir)
    trace_data_subdir = fullfile(data_par_dir, 'TraceData');
    trace_analysis_subdir = fullfile(data_par_dir, 'TraceAnalysis');
    mkdir(fullfile(trace_analysis_subdir, 'TraceText'));
    trace_filenames = getTraceCell(trace_data_subdir);
    collectData(trace_filenames, trace_data_subdir, trace_analysis_subdir);
end

function trace_cell = getTraceCell(pardir)
    dir_struct = dir(pardir);
    file_arr = {dir_struct(3:end).name};
    isDir_arr = {dir_struct(3:end).isdir};
    trace_cell = cell(1, length(file_arr)-3);
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
        fid = fopen(txt_filepath, 'a+');
        sz = size(data_struct.VirusDataToSave);
        num_particles = sz(2);
        DataToSave = struct();
        DataToSave.CombinedAnalyzedTraceData = data_struct.VirusDataToSave(1);
        counter = 1;
        for j=1:num_particles
            if strcmp(data_struct.VirusDataToSave(j).IsVirusGood, 'n')
                continue;
            end
            y_vals = data_struct.VirusDataToSave(j).Trace_BackSub;
            len = length(y_vals);
            fprintf(fid, strcat('@', num2str(counter), '\n'));
            for k=1:len
                fprintf(fid, strcat(num2str(y_vals(k)), ','));
            end
            fprintf(fid, '\n');
            DataToSave.CombinedAnalyzedTraceData(counter) = data_struct.VirusDataToSave(j);
            counter = counter + 1;
        end
        save(fullfile(dst_dir,strcat(SrcDataFilenameSansExt,'-Rvd','.mat')),'DataToSave');
        fclose(fid);
    end
end
