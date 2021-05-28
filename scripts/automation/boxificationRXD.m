% Make sure to put BoxData & corresponding .tifs in Originals subdir
function boxificationRXD(SaveParentFolder)
    trace_analysis_dir = fullfile(char(SaveParentFolder), 'TraceAnalysis', 'AnalysisRXD');
    trace_filename_list = getFileList(trace_analysis_dir);
    correlations = getCorrelations(SaveParentFolder);
    box_data_subdir = fullfile(char(SaveParentFolder), 'BoxyVideos', 'RXD', 'BoxData');
    mkdir(box_data_subdir);
    for i=1:length(trace_filename_list)
        curr_trace_analysis_filename = trace_filename_list(i);
        correlating_label = "";
        for j=1:length(trace_filename_list)
            curr_label = correlations(1,j);
            if contains(curr_trace_analysis_filename, curr_label)
                correlating_label = curr_label;
            end
        end
        boxy_filename = strcat("BoxyVid-RXD-", correlating_label, ".tif");
        dst_filepath = fullfile(box_data_subdir, char(boxy_filename));
        trace_filepath = fullfile(char(trace_analysis_dir), char(curr_trace_analysis_filename));
        overlayFusionBoxes(trace_filepath, dst_filepath);
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
