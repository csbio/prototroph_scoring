function [wild_type_matrix] = extract_wild_type_matrix(plate_struct, colony_data)
% [wild_type_matrix] = extract_wild_type_matrix(plate_struct, colony_data)
%
% Takes a struct of plates and the experimental design struct, and condenses
% the plate_data into a wild-type strains by conditions matrix. 
% This is a modified version of build_data_matrix.
%
% INPUTS
% ------
% plate_struct -- struct(num_plates, num_conds). Should have entries labeled
% "data" representing one row*column plate matrix. 16x24 for the condition
% project datasets.
%
% colony_data -- experimental design and data struct
%
% OUTPUTS
% -------
% wild_type_matrix -- genes x conditions matrix containing scores
%
    
    [num_conds, num_plates] = size(plate_struct);
    deletion_id = colony_data.deletion_id;
    condition = colony_data.condition';
    plate = colony_data.platenum;
    row = colony_data.row;
    column = colony_data.column;
    time0 = colony_data.time == 0;
    valid_plates = plate <= 15;
    WT_ID = strmatch('wild-type', colony_data.deletion_library);

    num_dels = max(deletion_id);
    del_bv_lookup = cell(num_dels, 1);

    % Precompute the deletion bool vectors. This provides a nice speedup.
    fprintf('Extracting a WT matrix\n');
    fprintf('\tPrecomputing useful information...\n');
    %for deletion = 1:num_dels
    for deletion = WT_ID
        del_bv_lookup{deletion} = time0 & (deletion_id == deletion);
    end

    for growth_cond = 1:num_conds
        fprintf('\r\tGrowth condition (37): %d ', growth_cond);
        bv_base = condition == growth_cond & valid_plates;
        %for deletion = 1:num_dels
        for deletion = WT_ID
            bv = del_bv_lookup{deletion} & bv_base;
            p = find(bv);
            physical_locations = numel(p);
            % Checking for multiple experimental replicates of the same deletion
            zs = nan(physical_locations, 1);
            ind = 1;
            for loc = p'
                zs(ind) = plate_struct(growth_cond, plate(loc)).data(row(loc), column(loc));
                ind = ind + 1;
            end
            wild_type_matrix(:, growth_cond) = zs;
        end
    end
    fprintf('\n');
