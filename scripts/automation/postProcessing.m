function postProcessing()
    SaveParentFolder = uigetdir();    
    batchCDF(SaveParentFolder);
    auto_dir = cd;
    
    info_filepath = fullfile(char(SaveParentFolder), 'info.txt');
    filepaths_text_filename = 'filepaths_EXTRACTION.txt';
    filepaths_text_filename = convertCharsToStrings(filepaths_text_filename);
    file_id = fileread(filepaths_text_filename);
    filepaths_cell_arr = strsplit(file_id);
    ij_path = filepaths_cell_arr(4);
    kasson_lib_directory = filepaths_cell_arr(5);

    UserReviewModified(SaveParentFolder);
    cd(auto_dir);
    boxificationRXD(SaveParentFolder);
    
    box_ij_arg = [info_filepath, ',', 'RXD'];
    boxification_macro_path = fullfile(kasson_lib_directory, 'LipidViralAnalysis', 'bin', 'boxification.ijm');
    command = strcat(ij_path, " -macro ", boxification_macro_path, " ", box_ij_arg);
    system(command);
    pdf_macro_path = fullfile(kasson_lib_directory, 'LipidViralAnalysis', 'bin', 'tiff_to_pdf.ijm');
    trace_drawings_subdir = fullfile(SaveParentFolder, 'TraceAnalysis', 'TraceDrawings');
    pdf_ij_arg = [trace_drawings_subdir, filesep];
    command = strcat(ij_path, " -macro ", pdf_macro_path, " ", pdf_ij_arg);
    system(command);
    exit();
end