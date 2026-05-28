function [north_west, north, north_east, west, centre, east, south_west, south, south_east] = get_neighbour_matrices(matrix)
    centre = matrix;

    north = shift(centre, 1, 1);
    south = shift(centre, 1, 0);
    east = shift(centre, 1, 2);
    west = shift(centre, 1, 3);
    
    north_east = shift(north, 1, 2);
    north_west = shift(north, 1, 3);
    south_east = shift(south, 1, 2);
    south_west = shift(south, 1, 3);
end