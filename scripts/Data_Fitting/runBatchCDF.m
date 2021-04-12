function runBatchCDF()
    cdf_par_dir = cd;
    rev_dir = uigetdir();
    dir_struct = dir(rev_dir);
    cd '..';
    cd '..';
    mkdir('CDF_Plots');
    dst_dir = fullfile(cd, 'CDF_Plots');
    len = length(dir_struct);
    for i=3:len
        rxd_mat_filename = dir_struct(i).name;
        rxd_mat_filepath = fullfile(dir_struct(i).folder, rxd_mat_filename);
        cd(cdf_par_dir);
        Start_Fit_Multiple_CDF('batch', rxd_mat_filepath);
        cleanupFigures(dst_dir, rxd_mat_filename);
    end
end

function cleanupFigures(data_dst_directory, filename)
    subdir_names_arr = ['PropMix', 'Fused', 'Residuals'];
    for i=1:length(subdir_names_arr)
        curr_subdir = fullfile(data_dst_directory, subdir_names_arr(i));
        if ~exist(curr_subdir, 'dir')
            mkdir(curr_subdir);
        end
        handleFigure(i, curr_subdir, filename);
    end
    % don't keep fig-6
    close all;
end

function handleFigure(fig_num, current_subdirectory, mat_filename)
    fig = figure(fig_num);
    [~, filename, ~] = fileparts(mat_filename);
    filepath = fullfile(char(current_subdirectory), char(filename));
    saveas(fig, filepath, 'tiffn');
    close(fig);
end
