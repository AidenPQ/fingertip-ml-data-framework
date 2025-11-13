% Author: Johannes Ringwald (MIRMI - TUM)
% Created: 01.02.2023

classdef(Abstract) PointCloudImportInterface
    methods(Abstract)
        pointcloud = import( filename );
    end %methods
end %class