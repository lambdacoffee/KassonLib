function postProcessing()
    SaveParentFolder = uigetdir();
    scripts_dir = cd;
    cd(fullfile(scripts_dir, 'Data_Fitting'));
    batchCDF(SaveParentFolder);
    
    info_filepath = fullfile(char(SaveParentFolder), 'info.txt');
    cd(fullfile(scripts_dir, 'lipid_mixing_analysis_scripts', 'ExtractTracesFromVideo'));
    filepaths_text_filename = 'filepaths.txt';
    filepaths_text_filename = convertCharsToStrings(filepaths_text_filename);
    file_id = fileread(filepaths_text_filename);
    filepaths_cell_arr = strsplit(file_id);
    ij_path = filepaths_cell_arr(4);
    
    cd(fullfile(scripts_dir, 'User_Review_Traces'));
    Start_User_Review_MODIFIED(SaveParentFolder);
    
    cd(fullfile(scripts_dir, 'lipid_mixing_analysis_scripts', 'ExtractTracesFromVideo'));
    BoxificationRXD(SaveParentFolder);
    
    box_ij_arg = [info_filepath, ',', 'RXD'];
    ij_dir = fileparts(char(ij_path));
    boxification_macro_path = fullfile(ij_dir, 'macros', 'KassonLib', 'LipidViralAnalysis', 'bin', 'boxification.ijm');
    command = strcat(ij_path, " -macro ", boxification_macro_path, " ", box_ij_arg);
    system(command);
    pdf_macro_path = fullfile(ij_dir, 'macros', 'KassonLib', 'LipidViralAnalysis', 'bin', 'tiff_to_pdf.ijm');
    trace_drawings_subdir = fullfile(SaveParentFolder, 'TraceAnalysis', 'TraceDrawings');
    pdf_ij_arg = [trace_drawings_subdir, filesep];
    command = strcat(ij_path, " -macro ", pdf_macro_path, " ", pdf_ij_arg);
    system(command);
    exit();
end