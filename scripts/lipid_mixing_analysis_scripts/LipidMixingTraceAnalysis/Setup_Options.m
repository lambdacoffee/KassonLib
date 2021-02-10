
function [Options] = Setup_Options(options_filepath)
    
    file_id = fileread(char(options_filepath));
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
end
