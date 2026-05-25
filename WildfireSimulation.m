classdef WildfireSimulation
    properties
        % Scalar attributes
        constant_ignition_probability % p_h (A. Alexandridis, et. al, p. 195)
        wind_speed
        wind_direction
        current_generation % Generation number of the simulation

        % Matrix attributes
        state {mustBeMatrix, mustBeUnderlyingType(state, "CellState")}        % Matrix of cell state enums
        vegetation {mustBeMatrix, mustBeUnderlyingType(vegetation, "double")} % Matrix of vegetation ignition probabilities
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
end