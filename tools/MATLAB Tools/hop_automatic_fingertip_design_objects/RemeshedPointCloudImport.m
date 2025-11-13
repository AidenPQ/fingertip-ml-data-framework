% Author: Johannes Ringwald (MIRMI - TUM)
% Created: 01.02.2023

classdef RemeshedPointCloudImport < PointCloudImportInterface
    methods
        % import_as_remeshed_point_cloud
        function pointcloud = import(~, filename )
            model = createpde(1);
            importGeometry( model, filename );
            generateMesh( model );
            point_list = model.Mesh.Nodes';
            pointcloud = pointCloud( point_list );
        end
    end %methods
end %class