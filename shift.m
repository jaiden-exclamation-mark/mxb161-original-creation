function shifted = shift(matrix, amount, direction)
% SHIFT  Shift all elements of a matrix in a specific direction and pad with 0s.
%
% Arguments:
%   `matrix` - The matrix to be shifted.
%   `amount` - The amount of rows/columns to shift by.
%   `direction` - The direction to shift the matrix. 0 is for upwards, 1 is for downwards, 2 is for leftward, 3 is for rightward.
% Returns:
%   `shifted` - The shifted matrix.

    [height, width] = size(matrix);
    if direction == 0
        padding = zeros(amount, width);
        shifted = [matrix(amount + 1:end, :); padding];
    elseif direction == 1
        padding = zeros(amount, width);
        shifted = [padding; matrix(1:end - amount, :)];
    elseif direction == 2
        padding = zeros(height, amount);
        shifted = [padding, matrix(:, 1:end - amount)];
    else
        padding = zeros(height, amount);
        shifted = [matrix(:, amount + 1:end), padding];
    end
end