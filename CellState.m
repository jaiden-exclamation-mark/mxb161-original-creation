classdef CellState < uint32
    enumeration
        Uninitialised (0)
        
        % As per A. Alexandridis, et. al (p.194)
  
        NoFuel (1)     % This cell has no forest fuel. Can represent: rural areas with no vegetation, cities. Cannot burn.
        NotIgnited (2) % This cell contains fuel but hasn't ignited yet.
        Burning (3)    % This cell contains fuel that is burning.
        BurnedDown (4) % This cell conatined fuel that has burned down.
    end
end