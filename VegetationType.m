classdef VegetationType < double
    enumeration
        % TODO: classify vegetation and how they affect burning probability
        % Below is an example from Table 3 of the article I've been using to make this simulation.
        % However, these categories do not and will not fit our usecase, and will need to be changed.

        % Negative values mean it's less likely to ignite.
        Agricultural (-0.3)
        Thickets (0)
        % Positive values mean it's more likely to ignite.
        HallepoPine (0.4)
    end
end