function GlobalVars = getVars(source_directory)
    % Returns struct: GlobalVars with values read & set from
    % filepaths_EXTRACTION.txt & modality.txt
    % structure has following fields:
    %   - Mode
    %   - AutoDir
    %   - DefaultPathname
    %   - SaveParentFolder
    %   - ijPath
    %   - KassonLibDir
    %   - StackFilenames
    %   - StackParentPaths
    %   - NumberOfFiles
    %   - infoCorrelations
    
    GlobalVars = struct();
    
    if strcmp(source_directory, "")
        modality_path = 'modality.txt';
        filepaths_path = 'filepaths.txt';
    else
        modality_path = fullfile(char(source_directory), 'modality.txt');
        filepaths_path = fullfile(char(source_directory), 'filepaths.txt');
    end
    mode = fileread(modality_path);
    GlobalVars.Mode = str2double(mode);
    file_id = fileread(filepaths_path);
    filepaths_cell_arr = strsplit(file_id, "\n");
    len = size(filepaths_cell_arr);
    
    GlobalVars.DefaultPathname = filepaths_cell_arr{1};
    GlobalVars.SaveParentFolder = filepaths_cell_arr{2};
    GlobalVars.ijPath = filepaths_cell_arr{3};
    GlobalVars.KassonLibDir = filepaths_cell_arr{4};
    vid_full_filepaths = filepaths_cell_arr(5:len(2)-1);
    len = length(vid_full_filepaths);
    GlobalVars.StackFilenames = cell(1,len);
    GlobalVars.StackParentPaths = cell(1,len);
    for i=1:len
        full_filepath = char(vid_full_filepaths(1,i));
        [parent_path, filename, ext] = fileparts(full_filepath);
        GlobalVars.StackFilenames{1,i} = strcat(filename, ext);
        GlobalVars.StackParentPaths{1,i} = parent_path;
    end
    GlobalVars.NumberOfFiles = length(GlobalVars.StackFilenames);
    GlobalVars.infoCorrelations = getCorrelations(...
        GlobalVars.SaveParentFolder, GlobalVars.Mode);
end