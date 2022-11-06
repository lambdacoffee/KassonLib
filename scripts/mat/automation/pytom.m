function pytom(vars)
    src_par_dir = vars.SaveParentFolder;
    src_txt_files_dir = fullfile(src_par_dir, 'TraceAnalysis', 'FusionOutput');
    dir_struct = dir(src_txt_files_dir);
    file_arr = {dir_struct(3:end).name};
    dst_dir = fullfile(src_par_dir, 'TraceAnalysis', 'AnalysisReviewed');
    if ~isfolder(dst_dir)
        mkdir(dst_dir);
    end
    
    mode = vars.Mode;
    
    for i=1:length(file_arr)
        filename = char(file_arr{i});
        src_txt_filepath = fullfile(src_txt_files_dir, filename);
        fid = fopen(src_txt_filepath, 'r');
        txt = textscan(fid, '%s');
        src_mat_filename = txt{1}{1};
        src_mat_filepath = fullfile(src_par_dir, 'TraceAnalysis', src_mat_filename);
        num_traces = length(txt{1}) - 1;
        ind = strfind(filename, 'FusionOutput');
        dst_filename = [filename(1:ind-1), 'pyReviewed.mat'];
        dst_filepath = fullfile(dst_dir, dst_filename);
        data_struct = load(src_mat_filepath);
        dat = data_struct.DataToSave;
        for j=2:num_traces+1
            line = txt{1}{j};
            line_cell_arr = strsplit(line, ',');
            trace_num = str2double(line_cell_arr{1,1});
            status = str2double(line_cell_arr{1,2});
            isFusion = str2double(line_cell_arr{1,3});
            if mode == 1 || mode == 2
                time_interval = dat.CombinedAnalyzedTraceData(trace_num).TimeInterval;
            end
            if mode == 1
                fusion_start = str2double(line_cell_arr{1,4});
                fusion_end = str2double(line_cell_arr{1,5});
                if length(line_cell_arr) > 5
                    isExclusion = str2double(line_cell_arr{1,6});
                end
            elseif mode == 2
                binding = str2double(line_cell_arr{1,4});
                fusion_start = str2double(line_cell_arr{1,5});
                fusion_end = str2double(line_cell_arr{1,6});
                isExclusion = str2double(line_cell_arr{1,7});
            end
            
            curr_trace = dat.CombinedAnalyzedTraceData(trace_num);
            pHDrop = curr_trace.PHdropFrameNum;
            curr_trace.FusionData = struct();
            if status
                curr_trace.ChangedByUser = 'Reviewed By User';
            end
            if mode == 0
                time_interval = curr_trace.TimeInterval;
            end
            if isFusion && mode ~= 2
                % median_fusion_time = median(fusion_start, fusion_end);
                curr_trace.Designation = 'Fuse';
                curr_trace.FusionData.Designation = "1 Fuse";
                curr_trace.FusionData.FuseFrameNumbers = fusion_end;
                curr_trace.FusionData.FusionInterval = ...
                    (fusion_end - fusion_start) * time_interval;
                curr_trace.FusionData.pHtoFusionTime = ...
                    (fusion_start - pHDrop) * time_interval;
            elseif isFusion && mode == 2
                % median_fusion_time = median(fusion_start, fusion_end);
                curr_trace.Designation = 'Fuse';
                curr_trace.FusionData.Designation = "1 Fuse";
                curr_trace.FusionData.FuseFrameNumbers = fusion_end;
                curr_trace.FusionData.FusionInterval = ...
                    (fusion_end - fusion_start) * time_interval;
                curr_trace.FusionData.pHtoFusionTime = ...
                    binding * time_interval;
                curr_trace.FusionData.bindingToFusionTime = ...
                    (fusion_start - binding) * time_interval;
            else
                curr_trace.Designation = 'No Fusion';
                curr_trace.FusionData.Designation = 'No Fusion';
            end
            if isExclusion
                curr_trace.isExclusion = 1;
                dat.CombinedAnalyzedTraceData(trace_num).isExclusion = 1;
            else
                curr_trace.isExclusion = 0;
                dat.CombinedAnalyzedTraceData(trace_num).isExclusion = 0;
            end
            dat.CombinedAnalyzedTraceData(trace_num).ChangedByUser = 'Reviewed By User';
            dat.CombinedAnalyzedTraceData(trace_num).FusionData = struct();
            dat.CombinedAnalyzedTraceData(trace_num) = curr_trace;
        end
        fclose(fid);
        DataToSave = dat;
        save(dst_filepath, 'DataToSave');
    end
    clear;
end
