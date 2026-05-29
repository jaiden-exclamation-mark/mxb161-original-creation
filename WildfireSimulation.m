classdef WildfireSimulation
    properties
        % Scalar attributes
        constant_ignition_probability {mustBeBetween(constant_ignition_probability, 0, 1)} = 0 % p_h (A. Alexandridis, et. al, p. 195)
        continued_burn_probability {mustBeBetween(continued_burn_probability, 0, 1)} = 0
        wind_speed
        wind_direction
        current_generation % Generation number of the simulation
        slope_constant (1, 1) = 0; % Constant used in slope's effect on ignition probability 

        % Matrix attributes 
        state {mustBeMatrix, mustBeUnderlyingType(state, "uint32")} = uint32([])                                                             % Matrix of cell state enums
        vegetation {mustBeMatrix, mustBeBetween(vegetation, -1, 0), mustBeUnderlyingType(vegetation, "double")} = []                         % Matrix of vegetation ignition probabilities
        vegetation_density {mustBeMatrix, mustBeBetween(vegetation_density, -1, 0), mustBeUnderlyingType(vegetation_density, "double")} = [] % Matrix of vegetation densities
        slope_matrix {mustBeMatrix} = []
    end
    methods
        function obj = WildfireSimulation(state)
            arguments
                state {mustBeMatrix}
            end
            if (nargin ~= 1)
                error("Improper number of arguments given to WildfireSimulation constructor.");
            end
            obj.current_generation = 0;
            
            obj.state = state;
            obj.vegetation = zeros(size(state));
            obj.vegetation_density = zeros(size(state));
            obj.slope_matrix = zeros(size(state));
        end
        
        function obj = step(obj)
            % Progresses the wildfire simulation one step.

            [height, width] = size(obj.state);
            
            % Rules of cellular automata
            
            % 1: state(i,j,t) = NoFuel -> state(i,j,t+1) = NoFuel
            no_fuel_mask = obj.state == CellState.NoFuel;
            
            currently_not_ignited_mask = obj.state == CellState.NotIgnited;
            currently_burning_mask = obj.state == CellState.Burning;
            continued_burn_mask = currently_burning_mask & (rand(height, width) < obj.continued_burn_probability);
            snuffed_flames_mask = currently_burning_mask & ~continued_burn_mask;
            
            % 4: state(i,j,t) = Burning -> Moore neighbours have a ignition probability p_burn
            ignition_mask = currently_not_ignited_mask & (rand(height, width) < obj.get_ignition_probability_matrix());
            ignition_mask = ignition_mask & obj.get_burning_cell_neighbour_mask();
            
            burning_mask = continued_burn_mask | ignition_mask;
            not_ignited_mask = currently_not_ignited_mask & ~burning_mask;
            
            % 2: state(i,j,t) = Burning -> state(i,j,t+1) = BurnedDown
            % 3: state(i,j,t) = BurnedDown -> state(i,j,t+1) = BurnedDown
            burned_down_mask = (obj.state == CellState.BurnedDown) | snuffed_flames_mask;
            
            % Create evolved state matrix.
            next = CellState(zeros(height, width));
            next(no_fuel_mask) = CellState.NoFuel;
            next(not_ignited_mask) = CellState.NotIgnited;
            next(burning_mask) = CellState.Burning;
            next(burned_down_mask) = CellState.BurnedDown;
            
            obj.current_generation = obj.current_generation + 1;
            obj.state = next;
        end
        
        function plot(obj)
            % PLOT  Plots the given WildfireSimulation using a colour map.
            %
            % Each CellState is given a specific colour:
            % - CellState.NoFuel - grey.
            % - CellState.NotIgnited - green.
            % - CellState.Burning - red.
            % - CellState.BurnedDown - yellow.
            
            no_fuel_colour = [0.3, 0.3, 0.3];
            not_ignited_colour = [0, 0.7, 0.3];
            burning_colour = [1, 0, 0];
            burned_out_colour = [1, 0.8, 0];
            colormap([no_fuel_colour; not_ignited_colour; burning_colour; burned_out_colour]);

            imagesc(uint32(obj.state) - 1);
            axis equal;
            set(gca, 'CLim', [0, 4]);
            colorbar('Ticks', [1, 2, 3, 4] - 0.5, 'TickLabels', ["No Fuel", "Not Ignited", "Burning", "Burned Out"]);
            title("Wildfire simulation (Generation " + obj.current_generation + ")");
        end

        function obj = set_slope_matrix(obj, elevation_matrix)
            [height, width] = size(obj.state);
            slope_matrix = zeros(height, width);
    
            % Wildly inefficient but it only has to run once.
            % Implementation of slope matrix generation derived from Li, Xiaochi (2018)
            for row = 1:height
                for column = 1:width
                    sub_slope_matrix = zeros(3);
                    if row == 1 || row == height || column == 1 || column == width
                        rows = max(1, row - 1):min(height, row + 1);
                        cols = max(1, column - 1):min(width, column + 1);
                        slope_matrix(rows, cols) = sub_slope_matrix(length(rows), length(cols));
                        continue;
                    end
    
                    [nw, n, ne, w, c, e, sw, s, se] = get_neighbours(elevation_matrix, row, column);
                    root_2 = sqrt(2);
                    sub_slope_matrix = c * ones(3) - [
                        nw, n, ne;
                         w, c,  e;
                        sw, s, se
                    ];
                    sub_slope_matrix = sub_slope_matrix ./ [
                        root_2,      1, root_2;
                             1, root_2,      1;
                        root_2,      1, root_2
                    ];
                    sub_slope_matrix = atand(sub_slope_matrix);
    
                    slope_matrix(row + (-1:1), column + (-1:1)) = sub_slope_matrix;
                end
            end
    
            obj.slope_matrix = slope_matrix;
        end
    end

    methods (Access = private)

        function burning_neighbour_mask = get_burning_cell_neighbour_mask(obj)
            centre = obj.state == CellState.Burning;

            north = shift(centre, 1, 1);
            south = shift(centre, 1, 0);
            east = shift(centre, 1, 2);
            west = shift(centre, 1, 3);
            
            north_east = shift(north, 1, 2);
            north_west = shift(north, 1, 3);
            south_east = shift(south, 1, 2);
            south_west = shift(south, 1, 3);

            burning_neighbour_mask = north_west |  north | north_east | ...
                                           east | centre |       west | ...
                                     south_west |  south | south_east;
        end

        function probability = get_ignition_probability(obj, row, column)
            theta_s = obj.slope_matrix(row, column); % TODO
            slope_effect = exp(obj.slope_constant * theta_s);
            probability = obj.constant_ignition_probability         ...
                        * (1 + obj.vegetation(row, column))         ...
                        * (1 + obj.vegetation_density(row, column)) ...
                        * slope_effect;
        end

        function matrix = get_ignition_probability_matrix(obj)
            [height, width] = size(obj.state);
            matrix = zeros(height, width);
            for row = 1:height
                for column = 1:width
                    matrix(row, column) = obj.get_ignition_probability(row, column);
                end
            end
        end
    end
end