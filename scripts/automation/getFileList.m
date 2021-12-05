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
