% Author: Johannes Ringwald
% Created: 06.02.2023

classdef PtCloudTransfMultiSteps
    properties
        pc_transf_obj
    end %properties
    methods
        function obj = PtCloudTransfMultiSteps( ptcloud_single_transform_obj )
            %--
            obj.pc_transf_obj = ptcloud_single_transform_obj;
        end
        function pointcloud = transform(obj, repos_steps, pointcloud )
            %--
            for t_step=1:length(repos_steps)
                repos_step = repos_steps{t_step};
                position = repos_step{1};
                orientation = repos_step{2};
                pointcloud = obj.pc_transf_obj.transform( position, orientation, pointcloud);
            end
        end
    end %methods
end %class