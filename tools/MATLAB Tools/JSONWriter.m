classdef JSONWriter
    %JSONWRITER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function write2jsonfile(~, filename, struct2write)
            %METHOD1 Take the CAD file reference that are stored in a
            %structure and create a JSON file to store those reference
            x = jsonencode(struct2write,"PrettyPrint",true);
            file_path = strcat('jsonfiles/',filename);
            fid = fopen(file_path, 'w');
            fprintf(fid, '%s', x);
            fclose(fid);
        end
    end
end

