function z_plates = z_transform_plate(reference, normalized_plates, del_std)
% z_plates = z_transform_plate(reference, normalized_plates, del_std)
%
% Takes the reference condition, the rate struct, and the deletion specific
% standard deviations and computes z-scores.
%
% INPUTS
% ------
% reference -- The GA reference condition computed by construct_reference 
% normalized_plates -- The struct with form
%                       normalized_plates(growth_cond, plate).data containing 
%                       rate data.
% del_std -- The struct with form del_std(plate).data which has the deletion
% specific standard deviation calculated by build_std_dev_struct
%
% OUTPUTS
% -------
% z_plates -- A struct with the same form as normalized_plates containing
% z-scores.

z_plates = struct();
SHOWPLOT = 0;

fprintf('Computing z-scores for plate');
for plate = 1:16
    fprintf(' %d', plate);
    valid_in_standard = not(isnan(reference(plate).data) & isinf(reference(plate).data));
    for growth_cond = 1:37
        cond_rates = normalized_plates(growth_cond, plate).data;
        indices = valid_in_standard & not(isnan(cond_rates));
        indices = indices & not(isinf(cond_rates));

        stand_rates = reference(plate).data;
        stand_rates(not(indices)) = NaN;
        cond_rates(not(indices)) = NaN;

        diffs = cond_rates - stand_rates;
        sigma = nanstd(diffs(:));

        inliers = arrayfun(@(arg) abs(arg/sigma) < 4, diffs);
        stand_rates = stand_rates(inliers);
        [stand_rates, indices] = sort(stand_rates);

        % valid_diffs count toward plate std term (applied to each gene)
        valid_diffs = diffs(inliers);
        sigma = repmat(nanstd(valid_diffs), 16, 24);
        sigma = sqrt(sigma .^ 2 +  del_std(plate).data .^ 2);

        % z_plates keeps original outliers in "diffs"
        z_plates(growth_cond, plate).data =  diffs ./ sigma;
    end
end
fprintf('\n');
