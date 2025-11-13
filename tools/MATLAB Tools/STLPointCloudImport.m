% Author: Johannes Ringwald (MIRMI - TUM)
% Created: 01.02.2023

classdef STLPointCloudImport < PointCloudImportInterface
    methods
        % import_stl_as_point_cloud
        function pointcloud = import(~, filename )
            TR = stlread(filename);
            point_list = TR.Points;
            pointcloud = pointCloud( point_list );
            pointcloud.XLimits;
        end
    end %methods
end %class