% Author: Johannes Ringwald (MIRMI - TUM)
% Created: 06.02.2023

classdef (Abstract) FilePostProcessing
    methods(Abstract)
        data = process( data )
    end %methods
end %class