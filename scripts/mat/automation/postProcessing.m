function postProcessing()
    vars = getVars();
    pytom(vars.SaveParentFolder);
    batchCDF(vars.SaveParentFolder);
    handleBoxification(vars);
    cd(vars.AutoDir);
    
    postRelay_macro_path = fullfile(vars.KassonLibDir, ...
        'scripts', 'ijm', 'postRelay.ijm');
    command = strcat(vars.ijPath, " -macro ", postRelay_macro_path, ...
        " ", vars.SaveParentFolder);
    system(command);
%     exit();
end
