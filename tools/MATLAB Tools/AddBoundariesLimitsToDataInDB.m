classdef AddBoundariesLimitsToDataInDB
    %ADDCONTOURLIMITSTODATAINDB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mongodb
        list_documents
        list_collections
        list_documents_and_boundaries
    end
    
    methods
        function obj = AddBoundariesLimitsToDataInDB(database, collections)
            %ADDCONTOURLIMITSTODATAINDB Construct an instance of this class
            obj.mongodb = database;
            obj.list_collections = collections;
            obj.list_documents = obj.findAllDocuments();
            obj.list_documents_and_boundaries = obj.computeBoundariesForAllDatas();
        end
        
        function docs_list = findAllDocuments(obj)
            %findAllDocuments get all the documents from the database
            docs_list = struct("filename", {}, "fileDirectory", {}, "collection", {});
            for collec = obj.list_collections
                list_per_collection = find(obj.mongodb, collec);
                sz = max(size(list_per_collection));
                if iscell(list_per_collection)
                    for i = 1:sz
                        file_directory = arrange_escape_character(list_per_collection{i,1}.fileDirectory);
                        docs_list(end+1) = struct("filename", convertCharsToStrings(list_per_collection{i,1}.filename), "fileDirectory", convertCharsToStrings(file_directory), "collection", collec); 
                    end
                else
                    for i = 1:sz
                        file_directory = arrange_escape_character(list_per_collection(i).fileDirectory);
                        docs_list(end+1) = struct("filename", convertCharsToStrings(list_per_collection(i).filename), "fileDirectory", convertCharsToStrings(file_directory), "collection", collec); 
                    end
                end
            end
        end

        function output =  computeBoundariesForAllDatas(obj)
            %Take each loaded datas and compute the boundaries for each
            importClass = STLPointCloudImport();
            output = struct("filename", {}, "fileDirectory", {}, "boundaries", {}, "collection", {});
            for doc = obj.list_documents
                path_to_file = strcat(doc.fileDirectory , '\' ,doc.filename);
                pointcloud = importClass.import(path_to_file);
                boundaries = struct("XLimits", pointcloud.XLimits, "YLimits", pointcloud.YLimits, "ZLimits", pointcloud.ZLimits);
                output(end + 1) = struct("filename", doc.filename, "fileDirectory", doc.fileDirectory, "boundaries", boundaries, "collection", doc.collection);
            end
        end

        function numberofupdate = updateBoundariesInDB(obj)
            %Add the property boundaries for each data in the DB and fill
            %it with the corresponding boundaries
            sz = max(size(obj.list_documents_and_boundaries));
            numberofupdate = 0;
            q_Manager = QueryManager();
            for i = 1:sz
                find_struct = struct("filename", obj.list_documents_and_boundaries(i).filename);
                findquery = jsonencode(find_struct, "PrettyPrint",true);
                update_set_struct.set = struct("boundaries", obj.list_documents_and_boundaries(i).boundaries);
                updatequery = q_Manager.convert_from_struct_to_query(update_set_struct);
                numberofupdate = numberofupdate + update(obj.mongodb,obj.list_documents_and_boundaries(i).collection, findquery, updatequery);
                % F = parfeval(@update,4,obj.mongodb, obj.list_documents_and_boundaries(i).collection, findquery, updatequery);
                %numberofupdate = F;
            end
        end
    end
end

