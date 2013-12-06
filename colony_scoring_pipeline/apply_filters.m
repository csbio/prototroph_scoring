function [filtered_plates] = apply_filters(plate_struct, filter_cell)
% [filtered_plates] = apply_filters(plate_struct, filter_cell)
%
% Takes a struct of z-score plates and a cell array of filter functions. It
% applys the filter functions in the order that they appear to each plate in
% the plate struct returning a struct with the same layout, but filtered data.
%
% INPUTS
% ------
% plate_struct -- struct(num_plates, num_conds). Each entry is one
% row*column plate matrix. 16x24 for the condition project datasets.
%
% filter_cell -- A cell array of functions that take exactly one argument,
% which must be an array of arbitrary size and returns exactly one value, which
% must be an array of the same size as the input. All output sanity checking is
% the responsibility of the called functions.
%
% A note about using this: If the restriction of the single argument is too
% restrictive, think about using Matlab's anonymous functions and currying, or
% make a 1 argument function that is a wrapper for something more complicated.
%
% OUTPUTS
% -------
% Struct with same format as plate_struct containing filtered plates, assuming
% your filters are well-behaved.

[num_conds, num_plates] = size(plate_struct);
filtered_plates = struct();
for plate = 1:num_plates
    for growth_cond = 1:num_conds
        plate_data = plate_struct(growth_cond, plate).data;
        for filt = filter_cell
            % There must be a cleaner way to do this
            filt = filt{1};
            plate_data = filt(plate_data);
        end
        filtered_plates(growth_cond, plate).data = plate_data;
    end
end
