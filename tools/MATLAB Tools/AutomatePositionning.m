classdef AutomatePositionning
    %AUTOMATEPOSITIONNING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        y_measure = 1
        obj_processing_target_fields = {'indv_transf_steps_orientation', 'indv_transf_steps_position'}
        pc_fingerbase_data
        ipfb_obj
        pc_import
        %--
        filename_obj_infos_fingerbase = 'obj_data_fingerbase.json'
        %--
        json_writer
    end
    
    methods
        function obj = AutomatePositionning()
            %AUTOMATEPOSITIONNING Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj.create_fingerbase();
            obj.pc_import = STLPointCloudImport();
            obj.json_writer = JSONWriter();
            obj.pc_fingerbase_data = obj.ipfb_obj.import_process( obj.filename_obj_infos_fingerbase, obj.obj_processing_target_fields );
        end

        function pointcloud = center_pc_to_transform(obj, pc_filename)
            % to center the pointcloud in regard to the fingerbase
            pointcloud_base = obj.pc_import.import(pc_filename);
            repos_steps = obj.calc_repos_centering_steps(pointcloud_base, obj.pc_fingerbase_data.pointcloud);
            pointcloud = obj.transform_multi_steps(repos_steps, pointcloud_base);
        end

        function transf_step_rotation = compute_transf_steps_rotation(obj, pc_targetobj)
            % Compute the orientation necessary for the rotation step , the
            % objective is to align
            X_lim_length = pc_targetobj.XLimits(2) - pc_targetobj.XLimits(1);
            Y_lim_length = pc_targetobj.YLimits(2) - pc_targetobj.YLimits(1);
            Z_lim_length = pc_targetobj.ZLimits(2) - pc_targetobj.ZLimits(1);
            list_lmits_length = [X_lim_length, Y_lim_length, Z_lim_length];

            [Max_length, index] = max(list_lmits_length);
            transf_step_rotation = {};

            if index == 1
                transf_step_rotation{end+1} = {[0 0 0], [0 -90 0]};

                % [Max_length, index] = max([Y_lim_length, Z_lim_length]);
                % if index == 2
                %     transf_step_rotation{end+1} = {[0 0 0], [0 0 90]};
                % end

            elseif index == 2
                transf_step_rotation{end + 1} = {[0 0 0], [-90 0 0]};

                % [Max_length, index] = max([X_lim_length, Z_lim_length]);
                % if index == 1
                %     transf_step_rotation{end+1} = {[0 0 0], [0 0 90]};
                % end
            else
                transf_step_rotation{end+1} = {[0 0 0], [0 0 0]};

                % [Max_length, index] = max([X_lim_length, Y_lim_length]);
                % if index == 1
                %     transf_step_rotation{end+1} = {[0 0 0], [0 0 90]};
                % end
            end
        end

        function transf_step_translation = compute_transf_step_translation(obj, pc_rotatedobj)
            Z_length = pc_rotatedobj.ZLimits(2) - pc_rotatedobj.ZLimits(1);
            transf_step_translation = {};

            transf_step_translation{end+1} = {[0 0 -(1/3)*Z_length], [0 0 0]};
        end

        function json_operations = compute_all_transf_step(obj, pc_targetobj_filename)
            pc_centered_obj = obj.center_pc_to_transform(pc_targetobj_filename);
            transf_step_rotation = obj.compute_transf_steps_rotation(pc_centered_obj);

            json_operations.indv_transf_steps_orientation = transf_step_rotation;
            
            pointcloud_base = obj.pc_import.import(pc_targetobj_filename);
            repos_steps = transf_step_rotation;
            pc_rotate = obj.transform_multi_steps(repos_steps, pointcloud_base);
            repos_steps_center = obj.calc_repos_centering_steps(pc_rotate, obj.pc_fingerbase_data.pointcloud);
            pc_rotate_obj = obj.transform_multi_steps(repos_steps_center, pc_rotate);

            transf_step_translation = obj.compute_transf_step_translation(pc_rotate_obj);

            repos_steps_transl = transf_step_translation;
            pc_end = obj.transform_multi_steps(repos_steps_transl, pc_rotate_obj);

            json_operations.indv_transf_steps_translation = transf_step_translation;
        end

        function pc_end = json_operation_gen(obj, obj_name, pc_targetobj_files, varargin)
            
            p = inputParser;

            p.addRequired("obj_name",@(x)validateattributes(x,["string","char"],"scalartext"));
            p.addRequired("pc_targetobj_files",@(x)validateattributes(x,"cell", "row"));
            p.addParameter("position_steps",0);

            p.parse(obj_name,pc_targetobj_files,varargin{:});

            obj_name = char(p.Results.obj_name);
            position_steps = p.Results.position_steps;

            nb_files = max(size(pc_targetobj_files));

            
            
            if nb_files > 1
                json_op(nb_files).name = obj_name;
                json_op(nb_files).filename_STL = 1;
                json_op(nb_files).indv_transf_steps_orientation = 1;
                json_op(nb_files).indv_transf_steps_translation = 1;

                if isreal(position_steps)
                    for i=1:nb_files
                        pc_path = strcat(pc_targetobj_files{1,i}.fileDirectory, '/', pc_targetobj_files{1,i}.filename);
                        pos_steps = obj.compute_all_transf_step(pc_path);
    
                        json_op(i).name = pc_targetobj_files{1,i}.filename;
                        json_op(i).filename_STL = pc_path;
                        json_op(i).indv_transf_steps_orientation = pos_steps.indv_transf_steps_orientation;
                        json_op(i).indv_transf_steps_translation = pos_steps.indv_transf_steps_translation;
                    end
                else
                    for i=1:nb_files
                        pc_path = strcat(pc_targetobj_files{1,i}.fileDirectory, '/', pc_targetobj_files{1,i}.filename);
    
                        json_op(i).name = pc_targetobj_files{1,i}.filename;
                        json_op(i).filename_STL = pc_path;
                        json_op(i).indv_transf_steps_orientation = positions_steps.indv_transf_steps_orientation;
                        json_op(i).indv_transf_steps_translation = positions_steps.indv_transf_steps_translation;
                    end
                end
                jsonFile = strcat(obj_name, ".json");
                obj.json_writer.write2jsonfile(jsonFile, json_op);
            else
                json_op.name = pc_targetobj_files.filename;
                pc_path = strcat(pc_targetobj_files{1,1}.fileDirectory, '/', pc_targetobj_infos{1,1}.filename);
                json_op.filename_STL = pc_path;
                if isreal(position_steps)
                    pos_steps = obj.compute_all_transf_step(pc_path);
                    json_op.indv_transf_steps_orientation = pos_steps.indv_transf_steps_orientation;
                    json_op.indv_transf_steps_translation = pos_steps.indv_transf_steps_translation;
                else
                    json_op.indv_transf_steps_orientation = position_steps.indv_transf_steps_orientation;
                    json_op.indv_transf_steps_translation = position_steps.indv_transf_steps_translation;
                end
                jsonFile = strcat(obj_name, ".json");
                obj.json_writer.write2jsonfile(jsonFile, json_op);
            end
        end
        
        function obj = create_fingerbase(obj)
            %create_fingerbase initiate the fingerbase
            %--
            jimp_obj = JSONFileImport();
            jpp_obj = JSONPostProcessing();
            pctm_obj = PtCloudTransfMultiSteps( PtCloudTransformation() );
            % Fingerbase
            pcimp_obj = RemeshedPointCloudImport();
            obj.ipfb_obj = ImportProcessFingerbase( jimp_obj, jpp_obj, pcimp_obj, pctm_obj);
        end

        function pointcloud = transform_multi_steps(obj, repos_steps, pointcloud_base)
            %--
            for t_step=1:length(repos_steps)
                repos_step = repos_steps{t_step};
                position = repos_step{1};
                orientation = repos_step{2};
                pointcloud = obj.transform_single_step(position, orientation, pointcloud_base);
            end
        end
        
        function repos_steps = calc_repos_centering_steps(obj, pc_targetobj, pc_fingerbase)
            %--
            repos_steps = {};
            % Middle coordinates
            x_obj_m = obj.calc_mid_coordinate_point( pc_targetobj.XLimits );
            x_fb_m = obj.calc_mid_coordinate_point( pc_fingerbase.XLimits );
            % Reposition Step
            x_obj_repos = x_fb_m - x_obj_m; 
            y_obj_repos = -1*pc_targetobj.YLimits(1) + obj.y_measure;
            z_obj_repos = -1*pc_targetobj.ZLimits(1);
            %---
            repos_steps{end+1} = {[x_obj_repos y_obj_repos z_obj_repos], [0 0 0]};
        end

        function point_middle = calc_mid_coordinate_point(~, pc_coord_limits)
            point_middle = ( pc_coord_limits(2) - pc_coord_limits(1) )/2 + pc_coord_limits(1);
        end

        function ptcloud_trans = transform_single_step(obj, pos_vec, rot_vec, ptcloud_origin)
            %--
            rot = obj.create_rotation_matrix( rot_vec );
            tform = rigid3d(rot, pos_vec);
            ptcloud_trans = pctransform( ptcloud_origin, tform);
        end
        function rot_mat = create_rotation_matrix(~, rot_vec )
            %--
            rot_mat = rotx( rot_vec(1) )*roty( rot_vec(2) )*rotz( rot_vec(3) );
        end
    end
end

