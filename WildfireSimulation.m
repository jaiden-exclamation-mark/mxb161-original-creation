classdef WildfireSimulation
    properties
        % Scalar attributes
        constant_ignition_probability {mustBeBetween(constant_ignition_probability, 0, 1 )} = 0 % p_h (A. Alexandridis, et. al, p. 195)
        wind_speed
        wind_direction
        current_generation % Generation number of the simulation

        % Matrix attributes
        state {mustBeMatrix, mustBeUnderlyingType(state, "uint32")} = uint32([]) % Matrix of cell state enums
        vegetation {mustBeMatrix, mustBeBetween(vegetation, 0, 1)} = []          % Matrix of vegetation ignition probabilities
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
        end
        function plot(obj)
            % Plot given state matrix
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