classdef CellState < uint32
    enumeration
        Uninitialised (0)
        
        % As per A. Alexandridis, et. al (p.194)
        NoFuel (1)
        NotIgnited (2)
        Burning (3)
        BurnedDown (4)
    end
end