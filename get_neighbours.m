function [north_west, north, north_east, west, centre, east, south_west, south, south_east] = get_neighbours(matrix, row, column)
    north_shift = shift(matrix, 1, 1);
    south_shift = shift(matrix, 1, 0);
    east_shift = shift(matrix, 1, 2);
    west_shift = shift(matrix, 1, 3);
    
    north_east_shift = shift(north_shift, 1, 2);
    north_west_shift = shift(north_shift, 1, 3);
    south_east_shift = shift(south_shift, 1, 2);
    south_west_shift = shift(south_shift, 1, 3);

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