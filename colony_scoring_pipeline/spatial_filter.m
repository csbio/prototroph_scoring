function newdata = spatial_filter(currdata)
% newdata = spatial_filter(currdata)
%
% This function takes a matrix, and applies a median and average filter over
% a sliding local window.
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

    gausfilt = fspecial('gaussian',3,4);
    avgfilt = fspecial('average',3);

    newdata = currdata;
    tmp = currdata;

    % Pull out the extremes
    ind = tmp < fix(.05*min(tmp(:))) | tmp > fix(.95*max(tmp(:)));
    tmp(ind) = nanmean(tmp(:));

    % Fill in Nans with smoothed version of neighbors
    invalid_data = isnan(tmp);
    tmp(invalid_data) = nanmean(currdata(:));
    pre_filt = imfilter(tmp, gausfilt, 'symmetric');
    tmp(invalid_data) = pre_filt(invalid_data);

    % Compute and subtract filter
    filtered = medfilt2(tmp,[3,3]);
    filtered = imfilter(filtered, avgfilt, 'symmetric');
    newdata = newdata - (filtered - nanmean(filtered(:)));

    [r, c] = size(newdata);
    assert(r == 16 & c == 24, 'You tried to pass out a plate of the wrong size...');
    assert(isequal(isnan(currdata), isnan(newdata)), 'You clobbered some NaNs');
