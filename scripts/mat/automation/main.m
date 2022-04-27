function main()

% - - - - - - - - - - - - - - - - - - - - -

% Input:
% Run_Me_To_Start(), in this case the user navigates to the image video
%       stacks and also chooses the parent folder where the output analysis files will be saved
%   OR
% Run_Me_To_Start(DefaultPath), where DefaultPath is the directory to which 
%       the user will be automatically directed to find the image video
%       stacks. After choosing the video stacks, the user then chooses the 
%       parent folder where the output analysis files will be saved.
%   OR
% Run_Me_To_Start(DefaultPath,SavePath), where DefaultPath is as above, and 
%       SavePath is the parent folder where the output analysis files will be saved

% Output:
% A .mat file is created which saves all of the variables in the current 
% workspace. This file will be the input for the Lipid Mixing Trace Analysis program. Within 
% this file, the intensity traces for each viral particle which has been 
% found, together with additional data for each virus, will be in the 
% VirusDataToSave structure, as defined in Find_And_Analyze_Particles.m

% Note: This program has not been designed to process many videos sequentially,
% but it has been tested with individual video streams, so keep that 
% in mind if you choose to process many videos at once.

% By Bob Rawle, Kasson Lab, University of Virginia, 2016
% Published online in conjunction with:
% Rawle et al., Disentangling Viral Membrane Fusion from Receptor Binding 
% Using Synthetic DNA-Lipid Conjugates, Biophysical Journal (2016) 
% http://dx.doi.org/10.1016/j.bpj.2016.05.048
% - - - - - - - - - - - - - - - - - - - - -

    close all
    vars = getVars("");
    copyfile('modality.txt', fullfile(vars.SaveParentFolder, 'modality.txt'));
    copyfile('filepaths.txt', fullfile(vars.SaveParentFolder,'filepaths.txt'));
    runExtractionProcess(vars);
    disp("Extraction Complete.");
    cd(vars.AutoDir);
    if vars.Mode == 0
        disp("Analysis In Progress...");
        runTraceAnalysisProcess(vars);
        cd(vars.AutoDir);
    end
    disp("Translation in progress...")
    translate(vars);    
    disp("Boxification in progress...");
    trace_analysis_dir = fullfile(vars.SaveParentFolder, 'TraceAnalysis');
    handleBoxification(vars, trace_analysis_dir);

    info_filepath = fullfile(char(vars.SaveParentFolder), 'info.txt');
    boxification_macro_path = fullfile(vars.KassonLibDir, ...
        'scripts', 'ijm', 'boxification.ijm');
    boxy_arg = strcat(info_filepath, ",", "1");
    box_command = strcat(vars.ijPath, " -macro ", boxification_macro_path, ...
        " ", boxy_arg);
    if ispc
        py_command = strcat("python -m fusion_review ", vars.SaveParentFolder);
        system(box_command);
        system(strcat("start cmd.exe /c ", py_command));
    elseif isunix
        py_command = strcat("python3 -m fusion_review ", vars.SaveParentFolder);
        system(py_command);
    end
    disp("Analysis Complete - Terminating Process.");
    disp("Thank you.  Come again.")
    diary off
    exit;
end

