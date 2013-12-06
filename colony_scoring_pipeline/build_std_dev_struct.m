function del_std = build_std_dev_struct(normalized_plates)
% del_std = build_std_dev_struct(normalized_plates)

ga_conds = [1:4 18:19];
num_plates = 16;
[num_rows, num_cols] = size(normalized_plates(1, 1).data);
num_ga_conds = numel(ga_conds);

del_std = struct();
for platenum = 1:num_plates
    del_std(platenum).data = nan(num_rows, num_cols);
    for col = 1:num_cols
        for row = 1:num_rows
            del_data = nan(num_ga_conds, 1);
            for condition = ga_conds
                index_vec = ga_conds == condition;
                del_data(index_vec) = normalized_plates(condition, platenum).data(row, col);
            end
            del_std(platenum).data(row, col) = nanstd(del_data);
        end
    end
end
