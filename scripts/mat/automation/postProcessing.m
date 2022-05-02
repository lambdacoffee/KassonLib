function postProcessing()
    vars = getVars();
    pytom(vars.SaveParentFolder);
    batchCDF(vars.SaveParentFolder);
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
