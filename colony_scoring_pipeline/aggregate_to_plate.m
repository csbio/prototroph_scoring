function normalized_plates = aggregate_to_plate(plate_view)
% normalized_plates = aggregate_to_plate(plate_view)
% this is stripped down copy of apply_normalizations which unpacks the plate_view of the data
% to a more useful data structure. Downstream filter and smoothing tools require plate format
%

%non_ga_conds = [5:17 20:37];
PLATES = 16;
CONDS=37;
ROWS=16;
COLS=24;

all_conds = 1:CONDS;

normalized_plates(CONDS, PLATES).data = zeros(ROWS, COLS)+nan;

for plate = 1:PLATES
    plate_data = get_plate(plate_view, plate);

    % for growth_cond = non_ga_conds
    for growth_cond = all_conds

        normalized_plates(growth_cond, plate).data = nan(16, 24);

        indices = not(isnan(plate_data(growth_cond).plate));
        indices = indices & not(isinf(plate_data(growth_cond).plate));
        cond_rates = plate_data(growth_cond).plate(indices);     

        normalized_plates(growth_cond, plate).data(indices) = cond_rates;
    end
end
