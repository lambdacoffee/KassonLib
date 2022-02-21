% This script is for collating and combining the .mat output files for
% Dual Color Analysis & Reverse Find Analysis processing.
%
% {Creator} : Marcos Cervantes for the Kasson Lab

main();

function dirSearchMAT(pardir, tag)
    % This function recursively searches for .mat files and collates these
    % files together, based on if files contain the keyword.
    % User can change this keyword, seen below.
    
    keyword = 'ReverseFindAnalysis';
    file_label = 'Position-';
    file_struct = dir(pardir);
    file_struct = file_struct(3:end);
    collated_struct = struct();
    for i=1:length(file_struct)
        filename = file_struct(i).name;
        if ~file_struct(i).isdir
            continue;
        end
        if startsWith(filename, tag)
            subdir = fullfile(pardir, filename);
            subdir_file_struct = dir(subdir);
            subdir_file_struct = subdir_file_struct(3:end);
            for j=1:length(subdir_file_struct)
                curr_mat_file = subdir_file_struct(j).name;
                load(fullfile(subdir, curr_mat_file));
                ind = strfind(curr_mat_file, file_label);
                collated_struct(j).Label = str2double(curr_mat_file(length(file_label)+1:strfind(curr_mat_file,'.')-1));
                collated_struct(j).TotalVirus = BindingDataToSave.TotalVirusesBound;
                collated_struct(j).GoodVirus = BindingDataToSave.NumberGoodViruses;
                collated_struct(j).TotalColocalized = BindingDataToSave.NumberColocalizedTotal;
                collated_struct(j).GoodColocalized = BindingDataToSave.NumberColocalizedGood;
                collated_struct(j).TotalPercentage =  collated_struct(j).TotalColocalized / collated_struct(j).TotalVirus;
                collated_struct(j).GoodPercentage =  collated_struct(j).GoodColocalized / collated_struct(j).GoodVirus;
            end
            collated_table = struct2table(collated_struct);
            saveCSV(pardir, tag, collated_table);
        else
            dirSearchMAT(fullfile(pardir, filename), tag);
        end
    end
end

function saveCSV(pardir, tag, collated_table)
    % This function saves collated tables into .csv files
    
    dst_path = fullfile(pardir, strcat(tag, 'Colocalization.csv'));
    writetable(collated_table, dst_path, 'delimiter', ',');
end

function dirSearchCSV(pardir, tag, collated_data_file)
    % This function recursively searches for .csv files and collates
    % together into one.
    
    file_struct = dir(pardir);
    file_struct = file_struct(3:end);
    for i=1:length(file_struct)
        filename = file_struct(i).name;
        if file_struct(i).isdir
            dirSearchCSV(fullfile(pardir, filename), tag, collated_data_file);
        elseif startsWith(filename, tag) && endsWith(filename, '.csv')
            curr_table = readtable(fullfile(pardir, filename));
            if isfile(collated_data_file)
                % collated file exists, append to end
                collated_table = readtable(collated_data_file);
                collated_table = [collated_table; curr_table];
                writetable(collated_table, collated_data_file, 'delimiter', ',');
            else
                % collated file does not exist, create
                writetable(curr_table, collated_data_file, 'delimiter', ',');
            end
        else
            continue;
        end
    end
end

function combineTables(source_directory, tags)
    % This function combines tables from different collated process
    % outputs if there are more than one.
    
    combined_table_filepath = fullfile(source_directory, 'CombinedColocalization.csv');
    for i=1:length(tags)
        curr_tag = tags(i);
        table_filepath = fullfile(source_directory, strcat(curr_tag, 'CollatedColocalization.csv'));
        curr_table = readtable(table_filepath);
        if isfile(combined_table_filepath)
            combo_table = readtable(combined_table_filepath);
            sz = size(combo_table);
            blanks = {};
            for j=1:sz(2)
                blanks = [blanks, {NaN}];
            end
            combo_table(sz(1)+1, :) = blanks;
            combo_table = [combo_table; curr_table];
            writetable(combo_table, combined_table_filepath, 'delimiter', ',');
        else
            writetable(curr_table, combined_table_filepath, 'delimiter', ',');
        end
    end
end

function main()
    % This is the main function & entry point to this script.
    % User may specify the tags variable below to indicate which process
    % outputs are to be collated.
    % User must specify the parent directory for the source data.
    
    src_dir = uigetdir();
    tags = ["DualColor", "ReverseFind"];
    for i=1:length(tags)
        curr_tag = tags(i);
        dirSearchMAT(src_dir, curr_tag);
    end
    for i=1:length(tags)
        curr_tag = tags(i);
        dst_collated_data_filepath = fullfile(src_dir, strcat(curr_tag, 'CollatedColocalization.csv'));
        dirSearchCSV(src_dir, curr_tag, dst_collated_data_filepath);
    end
    if length(tags) > 1
        combineTables(src_dir, tags)
    end
end
