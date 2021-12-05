function postProcessing(SaveParentFolder)
    % SaveParentFolder = uigetdir();
    pytom(SaveParentFolder);
    batchCDF(SaveParentFolder);
    auto_dir = cd;
    analysis_revd_dir = fullfile(char(SaveParentFolder), ...
        'TraceAnalysis', 'AnalysisReviewed');
    handleBoxification(SaveParentFolder, analysis_revd_dir);
    
    filepaths_text_filename = 'filepaths_EXTRACTION.txt';
    file_id = fileread(filepaths_text_filename);
    filepaths_cell_arr = strsplit(file_id);
    ij_path = filepaths_cell_arr(4);
    kasson_lib_directory = filepaths_cell_arr(5);

    cd(auto_dir);
    
    postRelay_macro_path = fullfile(kasson_lib_directory, ...
        'LipidViralAnalysis', 'bin', 'postRelay.ijm');
    command = strcat(ij_path, " -macro ", postRelay_macro_path, ...
        " ", SaveParentFolder);
    system(command);
%     exit();
end
