% Author: Johannes Ringwald (MIRMI - TUM)
% Created: 03.02.2023

classdef JSONFileImport
    methods
        function data = import(~, filename ) 
            str = fileread(filename); % dedicated for reading files as text 
            data = jsondecode(str); % Using the jsondecode function to parse JSON from string 
        end
    end %methods
end %class