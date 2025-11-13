% Author: Johannes Ringwald (TUM - MIRMI)
% Created: 15.02.2023

classdef PtCloudTransformation
    properties
    end
    methods
        function obj = PtCloudTransformation()
        end
        function ptcloud_trans = transform(obj, pos_vec, rot_vec, ptcloud_origin )
            %--
            rot = obj.create_rotation_matrix( rot_vec );
            tform = rigid3d(rot, pos_vec);
            ptcloud_trans = pctransform( ptcloud_origin, tform);
        end
        function rot_mat = create_rotation_matrix(~, rot_vec )
            %--
            rot_mat = rotx( rot_vec(1) )*roty( rot_vec(2) )*rotz( rot_vec(3) );
        end
    end %methods
end %class