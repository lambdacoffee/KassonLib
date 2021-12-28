function correlations = getCorrelations(parent_dst_dir, mode)
    correlation_txt_filepath = fullfile(char(parent_dst_dir), 'info.txt');
    file_id = fileread(correlation_txt_filepath);
    temp_split_cell_arr = strsplit(file_id, "\n");
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
        correlations(3,i) = temp(1,3);  % R3 is extraction options filepath
        if mode
            correlations(4,i) = temp(1,4);  % R3 is analysis options filepath
        end
    end
end
