function plate_view = create_plate_view(plate_struct)
% plate_view = create_plate_view(plate_struct)
%
% Takes a struct of plates and flattens them into a single large matrix showing all the available
% plates in all the available conditions laid out in a grid form. Useful for visualizing the whole
% experimental layout.
%
% INPUTS
% ------
% plate_struct -- struct(num_plates, num_conds). Each entry is one
% row*column plate matrix. 16x24 for the condition project datasets.
%
% OUTPUTS
% -------
% plate_view -- matrix showing the values of each row/col on every plate on each condition. Plates
% and conditions are arranged in the order they ar found in the struct passed in

    % TODO -- how do I share buffer across the functions in this file and this file only without
    % passing it as an argument to insert_plate? How does Matlab's 'global' keyword work?
    buffer = 2;
    [num_conds, num_plates] = size(plate_struct);
    [rows, columns] = size(plate_struct(1, 1).data);

    num_output_columns = num_plates * (columns + buffer) - buffer;
    num_output_rows = num_conds * (rows + buffer) - buffer;
    plate_view = nan(num_output_rows, num_output_columns) ;

    for plate = 1:num_plates
        for c = 1:num_conds
            plate_view = insert_plate(plate_view, plate, c, plate_struct(c, plate).data, buffer);
        end
    end
end

function data_set = insert_plate(data_set, plate_number, condition, plate, buffer)
    [rows, columns] = size(plate);
    % Number of blanks columns/rows between plates

    % All "- 1"s are for offset arithmetic since Matlab counts from 0
    col_l = (columns + buffer) * (plate_number - 1) + 1;
    col_u = col_l + (columns - 1);
    row_l = (rows + buffer) * (condition - 1) + 1;
    row_u = row_l + (rows - 1);
    data_set(row_l:row_u, col_l:col_u) = plate;
end
