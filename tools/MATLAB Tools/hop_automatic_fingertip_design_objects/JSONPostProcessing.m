% Author: Johannes Ringwald (MIRMI - TUM)
% Created: 04.02.2023

classdef JSONPostProcessing < FilePostProcessing
    methods
        function data = process(obj, target_fields, data ) 
            for field_ind=1:length(target_fields)
                field_name = target_fields{field_ind};
                transf_data = data.( field_name );
                data.(field_name) = obj.json2cell( transf_data );
            end
        end
        function transf_steps_all = json2cell(~, transf_data )
            transf_steps_all = cell(size(transf_data,1),1);
            for step_ind=1:size(transf_data,1)
                transf_parts = cell(1,2);
                for tran_ind=1:size(transf_data,2)
                    transf_parts(tran_ind) = { reshape( transf_data(step_ind,tran_ind,:), 1,3 ) } ;
                end
                transf_steps_all{step_ind} = transf_parts;
            end
        end
    end %methods
end %class