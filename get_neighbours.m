function [north_west, north, north_east, west, centre, east, south_west, south, south_east] = get_neighbours(matrix, row, column)
    [north_west_shift, north_shift, north_east_shift, west_shift, ~, east_shift, south_west_shift, south_shift, south_east_shift] = get_neighbour_matrices(matrix);

    north_west = north_west_shift(row, column);
    north = north_shift(row, column);
    north_east = north_east_shift(row, column);
    west = west_shift(row, column);
    centre = matrix(row, column);
    east = east_shift(row, column);
    south_west = south_west_shift(row, column);
    south = south_shift(row, column);
    south_east = south_east_shift(row, column);
end