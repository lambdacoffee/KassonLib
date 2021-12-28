function postProcessing()
    vars = getVars();
    pytom(varss.SaveParentFolder);
    batchCDF(vars.SaveParentFolder);
    analysis_revd_dir = fullfile(vars.SaveParentFolder, ...
        'TraceAnalysis', 'AnalysisReviewed');
    handleBoxification(vars.SaveParentFolder, analysis_revd_dir);
    cd(vars.AutoDir);
    
    postRelay_macro_path = fullfile(vars.KassonLibDir, ...
        'scripts', 'ijm', 'postRelay.ijm');
    command = strcat(vars.ijPath, " -macro ", postRelay_macro_path, ...
        " ", vars.SaveParentFolder);
    system(command);
%     exit();
end
