function plate_layout = recover_slow_growers(plate_layout, voting)
% plate_layout = recover_slow_growers(plate_layout, voting)
% 
% Takes a struct of the form (condition, plate).data(rows, columns) and a
% struct with the form (index) containing condition, plate, rows, cols, and
% score fields. Cases of missing data are held in the voting struct at the
% locations specified by its condition, plate, rows, and cols fields. These
% locations are assigned a value of 0 or kept as NaNs accoring the human
% judgment saved in voting's score field.
%
% INPUTS
% ------
% plate_layout -- See above.
%
% voting -- See above.
%
% OUTPUTS
% -------
% plate_layout -- Struct with same format as input, but some previously 
% missing data points have been transformed from NaNs to 0s, indicating that
% by human inspection, the data point in question was from a correctly plated
% colony that failed to thrive and is thus assigned a growth rate of 0.

n = numel(voting);

for index = 1:n
    condition = voting(index).condition;
    plate = voting(index).plate;
    r = voting(index).rows;
    c = voting(index).cols;
    verdict = voting(index).score;
    
    if verdict
        replacement_value = 0;
    else
        replacement_value = NaN;
    end

    plate_layout(condition, plate).data(r, c) = replacement_value;
end
