function postProcessing(parent_directory)
    vars = getVars(parent_directory);
    pytom(vars.SaveParentFolder);
    batchCDF(vars.SaveParentFolder, vars.Mode);
    trace_analysis_rvd_dir = fullfile(vars.SaveParentFolder, ...
        'TraceAnalysis', 'AnalysisReviewed');
    handleBoxification(vars, trace_analysis_rvd_dir);
    cd(vars.AutoDir);
    
    postRelay_macro_path = fullfile(vars.KassonLibDir, ...
        'scripts', 'ijm', 'postRelay.ijm');
    command = strcat(vars.ijPath, " -macro ", postRelay_macro_path, ...
        " ", vars.SaveParentFolder);
    system(command);
%     exit();
end
