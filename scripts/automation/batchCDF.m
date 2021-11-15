function batchCDF(SaveParentFolder)
    rescored_subdir = fullfile(SaveParentFolder, 'TraceAnalysis', 'AnalysisReviewed');
    DefaultPathname = [rescored_subdir, filesep];
    dir_struct = dir(DefaultPathname);
    len = length(dir_struct);   % includes . & ..
    DataFilenames = cell(1,len-2);
    boringFilenames = {''};
    
    auto_dir = cd;
    addpath(auto_dir);
    cd ..
    scripts_dir = cd;
    cd(fullfile(scripts_dir, 'Data_Fitting'));

    for i=3:len
        curr_filename = dir_struct(i).name;
        ind1 = strfind(curr_filename, 'Datum-');
        substring = curr_filename(ind1 + length('Datum-'):end);
        ind2 = strfind(substring, '-');
        datum_num = substring(1:ind2-1);
        datum_label = ['Datum-', datum_num];
        DataFilenames{1,i} = curr_filename;

        diary_filepath = fullfile(SaveParentFolder, 'Stats', 'Log', ['Stats_', datum_label,'.txt']);
        diary(char(diary_filepath));
        diary on;
        isFusion = fusionCheck(fullfile(DefaultPathname, curr_filename));
        if isFusion
            fitMultipleCDF_RXD(DefaultPathname, curr_filename, boringFilenames);
        else
            boringFilenames = [boringFilenames, curr_filename];
            disp("No instance of fusion detected.");
            continue;
        end
        diary off;

        handleFigs(SaveParentFolder, datum_label);
    end

    % Cumulative CDF
    diary_filepath = fullfile(SaveParentFolder, 'Stats', 'Stats_total.txt');
    diary(char(diary_filepath));
    diary on;
    fitMultipleCDF_RXD(DefaultPathname, DataFilenames, boringFilenames);
    diary off;
    handleFigs(SaveParentFolder, 'total');
end

function isFusion = fusionCheck(structure_filepath)
    % Ensures there is at least 1 fusion to use in CDF
    structure = load(structure_filepath);
    data = structure.DataToSave.CombinedAnalyzedTraceData;
    isFusion = 0;
    for i=1:length(data)
        designation = data(i).Designation;
        if strcmp(designation, 'Fuse')
            isFusion = 1;
            break;
        end
    end
end

function handleFigs(SaveParentFolder, datum_label)
    stats_subdirs = ["LipidMixEvents", "PropFusedGamma", "Residuals", "PropFused"];
    fig_nums = [1,2,3,6];
    num_figs = length(fig_nums);
    for j=1:num_figs
        fig = figure(fig_nums(j));
        curr_subdir_name = char(stats_subdirs(j));
        if ~strcmp(datum_label, 'total')
            curr_subdir = fullfile(SaveParentFolder, 'Stats', curr_subdir_name);
            fig_filepath = fullfile(char(curr_subdir), char(datum_label));
        else
            curr_filename = [curr_subdir_name, '_total.fig'];
            fig_filepath = fullfile(SaveParentFolder, 'Stats', curr_filename);
        end
        saveas(fig, fig_filepath, 'fig');
        close(fig);
    end
end
