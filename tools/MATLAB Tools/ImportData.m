classdef ImportData
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        field_positionning = ["usecase" "position"]
    end
    
    methods
        
        function docs_cell = import_from_one_collection(obj ,mongodbconn, collectname, varargin)
            %METHOD1 Summary of this method goes here
            %   Import documents / datas in the form of a structure array with
            %   the filename, directory and tags

            p = inputParser;

            p.addRequired("mongodbconn",@(x)validateattributes(x,"database.mongo.connection","scalar"));
            p.addRequired("collectname",@(x)validateattributes(x,["string","char"],"scalartext"));
            p.addParameter("Query",@(x)validateattributes(x,["string","char"],"scalartext"));

            p.parse(mongodbconn,collectname,varargin{:});

            collectname = char(p.Results.collectname);
            findquery = char(p.Results.Query);

            docs = find(mongodbconn, collectname, Query = findquery);
            sz = max(size(docs));

            docs_cell = cell(1, sz);

            if iscell(docs)
                for i=1:sz
                    file_directory = arrange_escape_character(docs{i,1}.fileDirectory);
                    fields = string(fieldnames(docs{i,1}));
                    fields_present = ismember(obj.field_positionning, fields);
                    if fields_present(1) && fields_present(2)
                        docs_cell{1,i} = struct("filename", convertCharsToStrings(docs{i,1}.filename), "fileDirectory", convertCharsToStrings(file_directory), "tags", convertCharsToStrings(docs{i,1}.tags), "usecase", convertCharsToStrings(docs{i,1}.usecase), "position", docs{i,1}.position);
                    else
                        docs_cell{1,i} = struct("filename", convertCharsToStrings(docs{i,1}.filename), "fileDirectory", convertCharsToStrings(file_directory), "tags", convertCharsToStrings(docs{i,1}.tags));
                    end
                end
            else
                for i=1:sz
                    file_directory = arrange_escape_character(docs(i).fileDirectory);
                    fields = string(fieldnames(docs(i)));
                    fields_present = ismember(obj.field_positionning, fields);
                    if fields_present(1) && fields_present(2)
                        docs_cell{1,i} = struct("filename", convertCharsToStrings(docs(i).filename), "fileDirectory", convertCharsToStrings(file_directory), "tags", convertCharsToStrings(docs(i).tags), "usecase", convertCharsToStrings(docs(i).usecase), "position", docs(i).position);
                    else
                        docs_cell{1,i} = struct("filename", convertCharsToStrings(docs(i).filename), "fileDirectory", convertCharsToStrings(file_directory), "tags", convertCharsToStrings(docs(i).tags));
                    end
                end
            end

        end
    end
end

