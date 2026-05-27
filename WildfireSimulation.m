classdef WildfireSimulation
    properties
        % Scalar attributes
        constant_ignition_probability {mustBeBetween(constant_ignition_probability, 0, 1)} = 0 % p_h (A. Alexandridis, et. al, p. 195)
        continued_burn_probability {mustBeBetween(continued_burn_probability, 0, 1)} = 0
        wind_speed
        wind_direction
        current_generation % Generation number of the simulation

        % Matrix attributes 
        state {mustBeMatrix, mustBeUnderlyingType(state, "uint32")} = uint32([])  % Matrix of cell state enums
        vegetation {mustBeMatrix, mustBeBetween(vegetation, -1, 0)} = []          % Matrix of vegetation ignition probabilities
    end
    methods
        function obj = WildfireSimulation(state, vegetation)
            arguments
                state {mustBeMatrix}
                vegetation {mustBeMatrix}
            end
            if (nargin ~= 2)
                error("Improper number of arguments given to WildfireSimulation constructor.");
            end
            obj.current_generation = 0;

            if (size(state) ~= size(vegetation))
                error("State matrix must be the same size as the vegetation matrix.");
            end
            
            obj.state = state;
            obj.vegetation = vegetation;
        end
        
        function obj = step(obj)
            % Progresses the wildfire simulation one step.

            [height, width] = size(obj.state);
            next = obj.state;
            
            % Rules of cellular automata
            % 1: state(i,j,t) = NoFuel -> state(i,j,t+1) = NoFuel
            % 2: state(i,j,t) = Burning -> state(i,j,t+1) = BurnedDown
            % 3: state(i,j,t) = BurnedDown -> state(i,j,t+1) = BurnedDown
            % 4: state(i,j,t) = Burning -> Moore neighbours have a ignition probability p_burn

            % TODO: eliminate this double for loop in lieu of finding a mask for each CellState
            
            no_fuel_mask = next == CellState.NoFuel;
            
            currently_not_ignited_mask = next == CellState.NotIgnited;
            currently_burning_mask = next == CellState.Burning;
            continued_burn_mask = currently_burning_mask & (rand(height, width) < obj.continued_burn_probability);
            snuffed_flames_mask = currently_burning_mask & ~continued_burn_mask;
            
            ignition_mask = currently_not_ignited_mask & (rand(height, width) < obj.get_ignition_probability_matrix());
            ignition_mask = ignition_mask & obj.get_burning_cell_neighbour_mask();

            burning_mask = continued_burn_mask | ignition_mask;

            not_ignited_mask = currently_not_ignited_mask & ~burning_mask;
            
            burned_down_mask = (next == CellState.BurnedDown) | snuffed_flames_mask;

            next(no_fuel_mask) = CellState.NoFuel;
            next(not_ignited_mask) = CellState.NotIgnited;
            next(burning_mask) = CellState.Burning;
            next(burned_down_mask) = CellState.BurnedDown;

            % for row = 1:height
            %     for column = 1:width
            %         next(row, column) = obj.get_next_cell_state(row, column);
            %     end
            % end
            
            obj.current_generation = obj.current_generation + 1;
            obj.state = next;
        end
        
        function plot(obj)
            % Plots the given WildfireSimulation using a colour map.
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
            colorbar()
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
            wind_probability = 1; % TODO
            probability = obj.constant_ignition_probability ...
                        * (1 + obj.vegetation(row, column)) ...
                        * wind_probability;
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
                
        function next_state = get_next_cell_state(obj, row, column)
            cell_state = obj.state(row, column);
            cell_wont_change = cell_state == CellState.NoFuel || cell_state == CellState.BurnedDown;
            if cell_wont_change
                next_state = cell_state;
                return;
            end
            
            switch cell_state
                case CellState.NotIgnited
                    % could i not just put the return values into the array without this temp value tomfoolery
                    [nw, n, ne, w, c, e, sw, s, se] = get_neighbours(obj.state, row, column);
                    neighbours = [nw, n, ne, w, c, e, sw, s, se];
                    
                    burning_mask = neighbours == CellState.Burning;
                    random_vector = rand(1, length(neighbours));
                    to_ignite = random_vector < obj.get_ignition_probability(row, column);
                    to_ignite = to_ignite & burning_mask;

                    if any(to_ignite)
                        next_state = CellState.Burning;
                    else
                        next_state = CellState.NotIgnited;
                    end
                case CellState.Burning
                    if rand() < obj.continued_burn_probability
                        next_state = CellState.Burning;
                    else
                        next_state = CellState.BurnedDown;
                    end
                otherwise
                    error("Uninitialised or invalid cell state '" + cell_state + "' at row " + row + ", column " + column);
            end
        end
    end
end