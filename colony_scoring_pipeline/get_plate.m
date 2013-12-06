function [query] = get_plate(data_set, plate_number, conditions)

if nargin < 3
    conditions = [1:37];
end

query = struct();

for condition = conditions
    col_l = 26 * (plate_number -1) + 1;
    row_l = 18 * (condition - 1) + 1;
    row_u = row_l + 15;
    col_u = col_l + 23;
    query(condition).plate = data_set(row_l:row_u, col_l:col_u);
end 
