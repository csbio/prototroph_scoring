function [condensed_matrix, ranges] = build_data_matrix(plate_struct, colony_data)
% [condensed_matrix, ranges] = build_data_matrix(plate_struct, colony_data)
%
% Takes a struct of plates and the experimental design struct, and condenses
% the plate_data into a deletions by conditions matrix. In the case of strains
% (for example, wild-type) with more than one replicate, the mean of all the
% available scores is taken. If more than one physical position exists, the
% difference between the highest and lowest score is recorded and can be
% returned as the second output argument.
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
% condensed_matrix -- genes x conditions matrix containing scores
%
% ranges -- genes x conditions matrix with the difference between highest and
% lowest score reported
    
    [num_conds, num_plates] = size(plate_struct);
    condensed_matrix = nan(4897, num_conds);
    ranges = nan(4897, 37);
    deletion_id = colony_data.deletion_id;
    condition = colony_data.condition';
    plate = colony_data.platenum;
    row = colony_data.row;
    column = colony_data.column;
    time0 = colony_data.time == 0;
    valid_plates = plate < 17;

    num_dels = max(deletion_id);
    del_bv_lookup = cell(num_dels, 1);

    % Precompute the deletion bool vectors. This provides a nice speedup.
    fprintf('Precomputing useful information...\n');
    for deletion = 1:num_dels
        del_bv_lookup{deletion} = time0 & (deletion_id == deletion);
    end

    fprintf('Growth condition ');
    for growth_cond = 1:37
        fprintf('%d ', growth_cond);
        bv_base = condition == growth_cond & valid_plates;
        for deletion = 1:num_dels
            bv = del_bv_lookup{deletion} & bv_base;
            p = find(bv);
            physical_locations = numel(p);
            % Checking for multiple experimental replicates of the same deletion
            if physical_locations == 1
                zs = plate_struct(growth_cond, plate(p)).data(row(p), column(p));
                ranges(deletion, growth_cond) = 0;
            else 
                zs = nan(physical_locations, 1);
                ind = 1;
                for loc = p'
                    zs(ind) = plate_struct(growth_cond, plate(loc)).data(row(loc), column(loc));
                    ind = ind + 1;
                end
                zs = nanmean(zs);
                ranges(deletion, growth_cond) = nanmax(zs) - nanmin(zs);
            end
            condensed_matrix(deletion, growth_cond) = zs;
        end
    end
    fprintf('\n');
