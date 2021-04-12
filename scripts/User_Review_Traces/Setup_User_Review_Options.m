
function [DataCounters, Options] = Setup_User_Review_Options()
    
    options_filename = 'UserReviewOptionsDefault.txt';
    file_id = fileread(char(options_filename));
    options_cell_arr = strsplit(file_id, '\n');
    len = length(options_cell_arr)-1;
    num_columns = count(options_cell_arr{1}, ',') + 1;
    new_cell_arr = cell(len, num_columns);
    for i=1:len
        split_cell = strsplit(options_cell_arr{i}, ',');
        for j=1:num_columns
            new_cell_arr{i,j} = split_cell{1,j};
            if ~isnan(str2double(new_cell_arr{i,j}))
                new_cell_arr{i,j} = str2double(new_cell_arr{i,j});
            elseif new_cell_arr{i,j} == "[]"
                new_cell_arr{i,j} = [];
            elseif startsWith(char(new_cell_arr{i,j}), '[') && length(char(new_cell_arr{i,j})) > 2
                new_cell_arr{i,j} = str2num(new_cell_arr{i,j});
            elseif new_cell_arr{i,j} == "NaN"
                new_cell_arr{i,j} = NaN;
            end
        end
    end
    fields = new_cell_arr(:,1);
    Options = cell2struct(new_cell_arr(:,2), fields, 1);
    Options.TotalNumPlots = Options.NumPlotsX*Options.NumPlotsY;
    
    DataCounters.CurrentTraceNumber = Options.StartingTraceNumber;
    DataCounters.CurrentErrorRate = 0;
    
    if strcmp(Options.AddPresetOptions, 'y')
        PresetOptionsDir = '/Users/bobrawle/Matlab/Virus Fusion Scripts/Preset Options/User Review Traces';
        [PresetOptionsFile, PresetOptionsDir] = uigetfile('*.m','Select pre-set options .m file',...
            char(PresetOptionsDir),'Multiselect', 'off');
        run(strcat(PresetOptionsDir,PresetOptionsFile));
    end
end
