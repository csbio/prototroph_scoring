function [z_pcl, z_cluster, z_scores_filtered, z_scores_raw, raw_rate_cluster, raw_wt_cluster] = ...
			condition_machine(colony_data, voting_results, window_size, fit_data, aggregate, plate_layout)
%function [z_pcl, z_cluster, z_scores_filtered, z_scores_raw, raw_rate_cluster] = condition_machine(colony_data, voting_results, window_size, fit_data, aggregate, plate_layout)
    
    if not(exist('window_size'))
        window_size = 0.6;
    end

    [fit_data, aggregate, plate_layout] = rate_measure_finalpix(colony_data);
    %if not(exist('fit_data') && exist('aggregate') && exist('plate_layout'))
        %[fit_data, aggregate, plate_layout] = rate_measure_slope(colony_data);
    %end

    % Construct reference
    [reference_condition, normalized_plates] = construct_reference(plate_layout, window_size);

    % Apply reference
    normalized_plates = apply_normalizations(plate_layout, reference_condition, normalized_plates, window_size);
    raw_rates_plates = aggregate_to_plate(plate_layout);

    % Alright, I think this is legit because we are inserting zeros. 
    normalized_plates = recover_slow_growers(normalized_plates, voting_results);

    del_std = build_std_dev_struct(normalized_plates);
    z_scores_raw = strain_var_z_transform_plate(reference_condition, normalized_plates, del_std); 

    filter_cell = {@row_col_smoothing, @spatial_filter};
    z_scores_filtered = apply_filters(z_scores_raw, filter_cell);
    raw_rates_filtered = apply_filters(raw_rates_plates, filter_cell);

    % Tiled version with buffers "human version"
    z_pcl = create_pcl_plate(z_scores_filtered);
    raw_rates_pcl = create_pcl_plate(raw_rates_filtered);

    % genes x conditions "matlab version"
    z_cluster = build_data_matrix(z_scores_filtered, colony_data);
    raw_rate_cluster = build_data_matrix(raw_rates_filtered, colony_data);
    raw_wt_cluster   = extract_wild_type_matrix(raw_rates_filtered, colony_data);

end

% plates are swapped, run this code once to fix them?
% remember to rename coloniesR
%fifteens  = find(coloniesR.platenum == 15 & coloniesR.condition' > 17);
%fourteens = find(coloniesR.platenum == 14 & coloniesR.condition' > 17);
%coloniesR.platenum(fifteens) = 14;
%coloniesR.platenum(fourteens) = 15;
%tmp = coloniesR.deletion_id(fifteens);
%coloniesR.deletion_id(fifteens) = coloniesR.deletion_id(fourteens);
%coloniesR.deletion_id(fourteens) = tmp;
%tmp = coloniesR.deletion(fifteens);
%coloniesR.deletion(fifteens) = coloniesR.deletion(fourteens);
%coloniesR.deletion(fourteens) = tmp;
