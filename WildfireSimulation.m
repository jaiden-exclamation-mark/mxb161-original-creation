classdef WildfireSimulation
    properties
        % Scalar attributes
        constant_ignition_probability {mustBeBetween(constant_ignition_probability, 0, 1 )} = 0 % p_h (A. Alexandridis, et. al, p. 195)
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
        
        function step(obj)
            % Step forward in the cellular automata

            [width, height] = size(obj.state);
            ignition_probabilities = zeros(width, height);
            % this is gross theres gotta be a better way to do this
            for row = 1:height
                for column = 1:width
                    ignition_probabilities(row, column) = obj.get_ignition_probability(row, column);
                end
            end
            ignition_probabilities

            % Rules of cellular automata
            % 1: state(i,j,t) = NoFuel -> state(i,j,t+1) = NoFuel
            % 2: state(i,j,t) = Burning -> state(i,j,t+1) = BurnedDown
            % 3: state(i,j,t) = BurnedDown -> state(i,j,t+1) = BurnedDown
            % 4: state(i,j,t) = Burning -> Moore neighbours have a ignition probability p_burn

        end
        function plot(obj)
            % TODO: Plot given state matrix
            error("TODO");
        end
    end
    methods (Access = private)
        function probability = get_ignition_probability(obj, row, column)
            probability = obj.constant_ignition_probability;
            probability = probability + (1 + obj.vegetation(row, column));
            wind_probability = 0;
            probability = probability + wind_probability;
        end
    end
end