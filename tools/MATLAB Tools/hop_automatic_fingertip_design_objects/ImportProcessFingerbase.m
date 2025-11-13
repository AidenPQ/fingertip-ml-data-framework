% Author: Johannes Ringwald (MIRMI - TUM)
% Created: 09.02.2023

classdef ImportProcessFingerbase
    properties
        jimp_obj
        jpp_obj
        pcimp_obj
        pctm_obj
    end %properties
    methods
        function obj = ImportProcessFingerbase(json_import_obj, json_process_obj, ptcloud_import_obj, ptcloud_multi_transf_obj)
            obj.jimp_obj = json_import_obj;
            obj.jpp_obj = json_process_obj;
            obj.pcimp_obj = ptcloud_import_obj;
            obj.pctm_obj = ptcloud_multi_transf_obj;
        end
        function result = import_process(obj, obj_data_filename, target_fields)
            %--
            [pointcloud, obj_data] = obj.import( obj_data_filename, target_fields );
            result = obj.transform( pointcloud, obj_data );
            result.obj_data = obj_data;
        end
        function [pointcloud, obj_data] = import(obj, obj_data_filename, target_fields)
            obj_data = obj.jimp_obj.import(obj_data_filename);
            obj_data = obj.jpp_obj.process( target_fields, obj_data );
            %pcimport_obj = RemeshedPointCloudImport();
            pointcloud = obj.pcimp_obj.import( obj_data.filename_STL );
        end
        function result = transform(obj, pointcloud, obj_data)
            pc_fingerbase_all = {};
            pc_fingerbase_all{end+1} = pointcloud;
            repos_steps = obj_data.indv_transf_steps_orientation;
            pointcloud = obj.pctm_obj.transform( repos_steps, pointcloud );
            pc_fingerbase_all{end+1} = pointcloud;
            %--
            result.pointcloud_history = pc_fingerbase_all;
            result.pointcloud = pointcloud;
        end
    end %methods
end %class