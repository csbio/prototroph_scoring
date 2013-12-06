function [newdata, nan_clobber]  = row_col_smoothing(currdata)
% newdata = row_col_smoothing(currdata)
%
% Given a matrix, a function is fit to the data using the row indices as
% independent variable. This "top to bottom" trend is removed, and then another
% function is fit against the column indices. This result is used to subtract
% any "left to right" trend.
%
% The filtered matrix is returned.
%
% INPUTS
% ------
% currdata -- Matrix to filter.
%
% OUTPUTS
% -------
% newdata -- Filtered matrix. Asserts check that the pattern of NaNs is
% unchanged, and the input and output matrix dimensions match.
    newdata = currdata;
    
    bad = isnan(currdata);
    for dimension = [1, 2]
        [fit_line, valid_data] = rc_smooth_helper(newdata, dimension);
        newdata(valid_data) = newdata(valid_data) - (fit_line - nanmean(fit_line));
    end

    newdata(not(valid_data)) = NaN;
    [r, c] = size(newdata);
    assert(r == 16 & c == 24, 'You tried to pass out a plate of the wrong size...');
    nan_clobber = ~isequal(isnan(currdata), isnan(newdata));
    if(nan_clobber)
        fprintf('You clobbered some NaNs\n');
    end
    %assert(isequal(isnan(currdata), isnan(newdata)), 'You clobbered some NaNs');
end

function [fitted_points, valid_data] = rc_smooth_helper(currdata, dimension)
    % Helper function which fits a smoothing function: i
    % f(position index) -> predicted z-score along the specified dimension
    % (1 = rows, 2 = columns) from an input plate. It returns the fit and the
    % locations of the points that had usable data.
    invalid_data = isnan(currdata);
    currdata(invalid_data) = nanmean(currdata(:));

    dims = size(currdata);

    r = dims(1);
    c = dims(2);
    d = dims(dimension);

    % Constructs a vector of column indices for use as independent variable:
    % [1, 1, 1, 1, ... , 2, 2, 2, 2, ... , ....]
    inds = arrayfun(@(index) floor((index-1)/(d))+1, [1:r*c]');
    unrolled = reshape(currdata, r*c, 1);
    valid_data = not(isnan(unrolled));
    unrolled = unrolled(valid_data);

    % Pull out extreme values 
    extreme_ind = (unrolled < fix(.05*min(unrolled(:)))) | (unrolled > fix(.95*max(unrolled(:))));
    unrolled(extreme_ind) = nanmean(unrolled(:));

    win_size = 0.5;
    fitted_points = smooth(inds, unrolled, win_size, 'rlowess');
end
