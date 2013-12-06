function normalized_plates = apply_normalizations(plate_view, normalize, normalized_plates, window_size)
% normalized_plates = apply_normalizations(plate_view, normalize, normalized_plates, window_size)
%

non_ga_conds = [5:17 20:37];
%all_conds = 1:37;
if not(exist('window_size'))
    window_size = 0.6;
end

for plate = 1:16
    valid_in_standard = not(isnan(normalize(plate).data) & isinf(normalize(plate).data));
    plate_data = get_plate(plate_view, plate);
    fprintf('Plate %d\n', plate);
    for growth_cond = non_ga_conds
%    for growth_cond = all_conds
        indices = valid_in_standard & not(isnan(plate_data(growth_cond).plate));
        indices = indices & not(isinf(plate_data(growth_cond).plate));
        stand_rates = normalize(plate).data(indices);
        cond_rates = plate_data(growth_cond).plate(indices);     

        lowess_line = smooth(stand_rates, cond_rates, window_size, 'rlowess');

        % Remove this comment after the next successful run
        normalized_plates(growth_cond, plate).data = nan(16, 24);
        normalized_plates(growth_cond, plate).data(indices) = stand_rates .* cond_rates ./ lowess_line;
    end
end
