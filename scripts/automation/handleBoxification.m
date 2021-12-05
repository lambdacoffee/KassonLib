function handleBoxification(parent_dst_dir, mat_dir)
    trace_filename_list = getFileList(mat_dir);
    correlations = getCorrelations(parent_dst_dir);
    box_data_subdir = fullfile(char(parent_dst_dir), 'Boxes', 'BoxData');
    if ~isfolder(box_data_subdir)
        mkdir(box_data_subdir);
    end
    mode = fileread('modality.txt');
    mode = str2double(mode);
    for i=1:length(trace_filename_list)
        [Options] = Setup_Options(correlations(3,i));
        curr_trace_analysis_filename = trace_filename_list(i);
        correlating_label = "";
        for j=1:length(trace_filename_list)
            curr_label = correlations(1,j);
            if contains(curr_trace_analysis_filename, curr_label)
                correlating_label = curr_label;
            end
        end
        if ~mode
            correlating_label = strcat(Options.Label, "_", correlating_label);
        end
        boxy_filename = strcat("Boxy_", correlating_label, ".tif");
        dst_filepath = fullfile(box_data_subdir, char(boxy_filename));
        trace_filepath = fullfile(char(mat_dir), char(curr_trace_analysis_filename));
        overlayFusionBoxes(trace_filepath, dst_filepath);
    end
end
