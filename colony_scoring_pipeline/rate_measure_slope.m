function [fit_data, aggregate, plate_layout, no_growth] = rate_measure_slope(colony_data)
    % Takes a colony_data struct and computes growth rates
    logfile = fopen('area_checks.log', 'w');

    % Pulling these out of the struct gives a marginal speedup, but it's a speedup
    % none the less
    % Plates 17 and 18 are irrelevant to this experiment
    plates = colony_data.platenum < 17;
    dels = unique(colony_data.deletion_id(plates))';
    areas = colony_data.area;
    unixtime = colony_data.unixtime;
    conditions = colony_data.condition';
    deletion_id = colony_data.deletion_id;

    % Fill these with NaNs. We could (in theory) have negative or zero slope, so
    % this will serve to warn us that the data is missing
    %% TODO -- Get rid of magic numbers
    fit_data = nan(37, max(dels)); % Note assumption that min(dels) >= 1
    plate_layout = nan(18*37-2, 26*18 -2);
    no_growth = nan(18*37-2, 26*18 -2);

    % These cell arrays have almost no impact on performance
    aggregate = struct();
    zero_mask = struct();
    record = struct('areas', [], 'unixtimes', [], 'rate', [], 'plate', [], 'row', [], 'column', []);
    for growth_cond = 1:37
        fprintf('On condition %d\n', growth_cond);
        conditions_bv = conditions == growth_cond & colony_data.platenum <= 16;
        for deletion = dels
            deletion_bv = (deletion_id == deletion) & conditions_bv; %---SLOW
            c = colony_data.column(deletion_bv);
            r = colony_data.row(deletion_bv);
            plates = colony_data.platenum(deletion_bv);

            [tuples, r_, c_] = unique([plates r c], 'rows');
            [number_of_occurrences, void] = size(tuples);
            rates = nan(number_of_occurrences, 1);
            validity_mat = zeros(number_of_occurrences, 1);
            local_record = struct(record);
            for occurrence = 1:number_of_occurrences
                % SO MUCH TIME IS SPENT HERE:
                loop_bv = deletion_bv & colony_data.platenum == tuples(occurrence, 1) & ...
                               colony_data.row == tuples(occurrence, 2) & ...
                               colony_data.column == tuples(occurrence, 3);
                a = areas(loop_bv);
                t = unixtime(loop_bv);
                [t, indices] = sort(t);
                if growth_cond == 18 || growth_cond == 19
                    t(end) = [];
                    indices(end) = [];
                end
                a = a(indices);
                
                [num_data_points, total_places] = size(a);
                if num_data_points ~= 4 || num_data_points ~= 5 %%% This will need to be addressed
                    good_indices = find(a);
                    if numel(good_indices) >= 2
                        good_a = cast(a(good_indices), 'double');
                        good_t = cast(t(good_indices) - t(1), 'double');
                        tmp = polyfit(good_t, good_a, 1);
                        rates(occurrence) = tmp(1);
                        if rates(occurrence) < 0
                            rates(occurrence) = 0;
                            validity_mat(occurrence) = 1;
                        end
                    end
                else
                    fprintf(2, 'Too many data points -- something fishy');
                    fprintf(2, 'Deletion: %d\nGrowth Condition: %d\n', del, growth_cond);
                    fprintf(2, 'Area: %d\nTime: %d\n', a, t);
                    fprintf(logfile, 'Too many data points\n');
                    fprintf(logfile, 'Growth Condition: %f\n', growth_cond);
                    fprintf(logfile, 'Deletion: %f\n', deletion);
                    fprintf(logfile, 'Areas: %f\n\n', a);
                end

                local_record(occurrence).areas = a;
                local_record(occurrence).unixtimes = t;
                if deletion == 4896
                    local_record(occurrence).rate = NaN;
                    rates(occurrence) = NaN;
                end
                local_record(occurrence).rate = rates(occurrence);

                local_record(occurrence).plate = tuples(occurrence, 1);
                p_ = tuples(occurrence, 1);

                local_record(occurrence).row = tuples(occurrence, 2);
                i_ = tuples(occurrence, 2);

                local_record(occurrence).column = tuples(occurrence, 3);
                j_ = tuples(occurrence, 3);
                r = i_ + 18 * (growth_cond - 1);
                c = j_ + 26 * (p_ - 1);

                % Is this the behavior we want? It will fill in a NaN if the 
                % growth rate data from this area is not usable
                plate_layout(r, c) = rates(occurrence);
                no_growth(r, c) = validity_mat(occurrence);
                zero_mask(growth_cond, deletion).data = validity_mat;
                aggregate(growth_cond, deletion).data = local_record;
                fit_data(growth_cond, deletion,:) = nanmean(rates);
            end
        end
    end
    fclose(logfile);
    save 'zero_mask.mat' fit_data aggregate plate_layout no_growth;
end
