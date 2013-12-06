function  [reference_condition, normalized_plates] = construct_reference(plate_view, window_size)
%[reference_condition, normalized_plates] = construct_reference(plate_view, window_size)
%
% INPUTS
% ------
% plate_view -- This input is really pretty bizzare.
% use get_plate to access plates
%
% window_size -- Defines the size of the moving window used by smooth function.
% This should be in the interval (0.0, 1.0]. Default value is 0.6 if not
% specified (this argument is optional).
%     |
%     |
%     |--- NOTE: This argument really only exists to make design and test 
%                easier. I suggest deleting this when shipping and using a 
%                hardcoded window size in the function body that corresponds to
%                whatever value in settled on for the publication data.
%
% OUTPUTS
% -------
% reference_condition -- struct of form (plate).data which will serve as a
% canonical Glucose/Ammonium condition for the rest of the model. It should be
% noted that this is a *DERIVED VALUE* and thus an idealization. There is no
% physical object in any lab corresponding to the numbers here.
%
% normalized_plates -- 
%       |
    if not(exist('window_size') == 1)
        window_size = 0.6;
    end

    % Setting up constants -- can be safely glossed over
    glucose_ammonium_conds = [1:4, 18:19];
    num_ga_conds = numel(glucose_ammonium_conds);
    num_plates = 16;
    dummy = get_plate(plate_view, 1, 1);
    [num_rows, num_cols] = size(dummy(1).plate);

    reference_condition = struct();
    normalized_plates = struct();

    for plate = 1:num_plates
        plate_data = get_plate(plate_view, plate, glucose_ammonium_conds);
        sums = nan(num_ga_conds, 1);

        % Find the GA replicate with the fewest missing data points. This is important as anything
        % missing in the constructed reference will be lost in all the experimental plates.
        for condition = glucose_ammonium_conds
            bv = condition == glucose_ammonium_conds;
            sums(bv) = sum(isnan(plate_data(condition).plate(:)));
        end
        [val, index] = min(sums);
        most_complete = plate_data(glucose_ammonium_conds(index)).plate;
        
        % Remove the most complete GA replicate. That will be used as the independent variable
        % against which the other five will be smoothed.
        others = glucose_ammonium_conds;
        others(index) = [];

        valid_in_standard = not(isnan(most_complete) & isinf(most_complete));
        data_collection = nan(num_ga_conds, num_rows, num_cols);
        data_collection(index, :,  :) = most_complete;

        for to_normalize = others
            indices = valid_in_standard & not(isnan(plate_data(to_normalize).plate));
            indices = indices & not(isinf(plate_data(to_normalize).plate));
            % At this point "indicies" is a boolean matrix where each entry is a 1 iff there is
            % valid data in both the independent reference GA replicate and the one to be smoothed
            stand_rates = most_complete(indices);
            cond_rates = plate_data(to_normalize).plate(indices);     
            smooth_rates = smooth(stand_rates, cond_rates, window_size, 'rlowess');

            normals = nan(num_rows, num_cols);
            % Perhaps this "contraction function" is not powerful enough.
            % Consider something like
            % normals(indices) = stand_rates .* (cond_rates ./ smooth_rates) .^ 2 ;
            normals(indices) = stand_rates .* cond_rates ./ smooth_rates;

            data_collection(to_normalize == glucose_ammonium_conds, :, :) = normals; 
            normalized_plates(to_normalize, plate).data = normals;
        end
        normalized_plates(glucose_ammonium_conds(index), plate).data = most_complete;
        reference_condition(plate).data = reshape(nanmean(data_collection), num_rows, num_cols);
    end
end
