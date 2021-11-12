function postProcessing(SaveParentFolder)
    % SaveParentFolder = uigetdir();
    pytom(SaveParentFolder);
    batchCDF(SaveParentFolder);
    auto_dir = cd;
    handleBoxification(SaveParentFolder);
    
    info_filepath = fullfile(char(SaveParentFolder), 'info.txt');
    filepaths_text_filename = 'filepaths_EXTRACTION.txt';
    filepaths_text_filename = convertCharsToStrings(filepaths_text_filename);
    file_id = fileread(filepaths_text_filename);
    filepaths_cell_arr = strsplit(file_id);
    ij_path = filepaths_cell_arr(4);
    kasson_lib_directory = filepaths_cell_arr(5);

    cd(auto_dir);
    
    boxification_macro_path = fullfile(kasson_lib_directory, 'LipidViralAnalysis', 'bin', 'boxification.ijm');
    command = strcat(ij_path, " -macro ", boxification_macro_path, " ", info_filepath);
    system(command);
    pdf_macro_path = fullfile(kasson_lib_directory, 'LipidViralAnalysis', 'bin', 'tiff_to_pdf.ijm');
    trace_drawings_subdir = fullfile(SaveParentFolder, 'TraceAnalysis', 'TraceDrawings');
    pdf_ij_arg = [trace_drawings_subdir, filesep];
    command = strcat(ij_path, " -macro ", pdf_macro_path, " ", pdf_ij_arg);
    system(command);
    exit();
end

function handleBoxification(parent_dst_dir)
    analysis_revd_dir = fullfile(char(parent_dst_dir), 'TraceAnalysis', 'AnalysisReviewed');
    trace_filename_list = getFileList(analysis_revd_dir);
    correlations = getCorrelations(parent_dst_dir);
    box_data_subdir = fullfile(char(parent_dst_dir), 'Boxes', 'BoxData');
    mkdir(box_data_subdir);
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
        correlating_label = strcat(Options.Label, "_", correlating_label);
        boxy_filename = strcat("Boxy_", correlating_label, ".tif");
        dst_filepath = fullfile(box_data_subdir, char(boxy_filename));
        trace_filepath = fullfile(char(analysis_revd_dir), char(curr_trace_analysis_filename));
        overlayFusionBoxes(trace_filepath, dst_filepath);
    end
end

function file_list = getFileList(parent_directory)
    file_list_struct = dir(parent_directory);  % includes . & ..
    dir_contents = struct2cell(file_list_struct);
    dir_contents = dir_contents(1,:,:);
    dir_contents = dir_contents(3:length(file_list_struct));
    isFile_arr = ~isfolder(fullfile(parent_directory, dir_contents));
    filenames = dir_contents(isFile_arr);
    file_list = strings(1,length(filenames));
    for i=1:length(filenames)
        file_list(1,i) = convertCharsToStrings(filenames{1,i});
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
    end
end
