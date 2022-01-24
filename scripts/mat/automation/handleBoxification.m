function handleBoxification(GlobalVars)
    trace_analysis_revd_dir = fullfile(GlobalVars.SaveParentFolder, ...
        'TraceAnalysis', 'AnalysisReviewed');
    trace_filename_list = getFileList(trace_analysis_revd_dir);
    box_data_subdir = fullfile(GlobalVars.SaveParentFolder, 'Boxes', 'BoxData');
    if ~isfolder(box_data_subdir)
        mkdir(box_data_subdir);
    end
    for i=1:length(trace_filename_list)
        curr_trace_analysis_filename = trace_filename_list(i);
        correlating_label = "";
        for j=1:length(trace_filename_list)
            curr_label = GlobalVars.infoCorrelations{1,j};
            if contains(curr_trace_analysis_filename, curr_label)
                correlating_label = curr_label;
            end
        end
        if ~GlobalVars.Mode
            [Options] = Setup_Options(GlobalVars.infoCorrelations{3,i});
            correlating_label = strcat(Options.Label, "_", correlating_label);
        end
        boxy_filename = strcat("Boxy_", correlating_label, ".tif");
        dst_filepath = fullfile(box_data_subdir, char(boxy_filename));
        trace_filepath = fullfile(trace_analysis_revd_dir, ...
            char(curr_trace_analysis_filename));
        overlayFusionBoxes(trace_filepath, dst_filepath);
    end
end
