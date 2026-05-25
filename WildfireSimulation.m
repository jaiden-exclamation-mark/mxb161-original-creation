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
            
            obj.state = state;
            obj.vegetation = vegetation;
        end
        
        function obj = step(obj)
            % Step forward in the cellular automata
            [height, width] = size(obj.state);
            next = obj.state;
            
            % Rules of cellular automata
            % 1: state(i,j,t) = NoFuel -> state(i,j,t+1) = NoFuel
            % 2: state(i,j,t) = Burning -> state(i,j,t+1) = BurnedDown
            % 3: state(i,j,t) = BurnedDown -> state(i,j,t+1) = BurnedDown
            % 4: state(i,j,t) = Burning -> Moore neighbours have a ignition probability p_burn

            for row = 1:height
                for column = 1:width
                    next(row, column) = obj.get_next_cell_state(row, column);
                end
            end
            
            obj.current_generation = obj.current_generation + 1;
            obj.state = next;
        end
        
        function plot(obj)
            % TODO: Plot given state matrix
            imagesc(uint32(obj.state));
        end
    end
    methods (Access = public)
        function probability = get_ignition_probability(obj, row, column)
            wind_probability = 1; % TODO
            probability = obj.constant_ignition_probability ...
                        * (1 + obj.vegetation(row, column)) ...
                        * wind_probability;
        end
        
        function neighbours = get_neighbours(obj, row, column)
            [height, width] = size(obj.state);
            neighbours = CellState(zeros(1, 9));
            for neighbour_index = 1:9
                % god i love 1-indexing
                row_delta = floor((neighbour_index - 1) / 3) - 1;
                column_delta = mod((neighbour_index - 1), 3) - 1;

                neighbour_row = row + row_delta;
                neighbour_column = column + column_delta;
                
                in_bounds = 0 < neighbour_row && neighbour_row <= height && ...
                            0 < neighbour_column && neighbour_column <= width;
                
                if in_bounds
                    neighbours(neighbour_index) = obj.state(neighbour_row, neighbour_column);
                else
                    neighbours(neighbour_index) = CellState.NoFuel;
                end
            end
        end
                
        function next_state = get_next_cell_state(obj, row, column)
            cell_state = obj.state(row, column);
            
            switch cell_state
                case CellState.NoFuel
                    next_state = CellState.NoFuel;
                case CellState.NotIgnited
                    neighbours = obj.get_neighbours(row, column);
                    for neighbour = neighbours
                        if neighbour == CellState.Burning
                            % This is where slope calculations and wind calculations would be.
                            % At this moment, it is not implemented.
                            ignition_probability = obj.get_ignition_probability(row, column);
                            if rand() < ignition_probability
                                next_state = CellState.Burning;
                                return;
                            end
                        end
                    end 
                    next_state = CellState.NotIgnited;
                case CellState.Burning
                    if rand() < obj.continued_burn_probability
                        next_state = CellState.Burning;
                    else
                        next_state = CellState.BurnedDown;
                    end
                case CellState.BurnedDown
                    next_state = CellState.BurnedDown;
                otherwise
                    error("Uninitialised or invalid cell state '" + cell_state + "' at row " + row + ", column " + column);
            end
        end
    end
end