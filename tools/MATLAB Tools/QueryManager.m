classdef QueryManager
    %QUERYMANAGER Summary of this class goes here
    %   Group of functions to create queries easily

    properties
        array_operators = {'"in"' '"all"' '"set"' '"push"' '"each"'}
    end
  
    methods

        function query = convert_from_struct_to_query(obj, struct_to_convert)
            % From a structure containing the operators without the char $,
            % it creates a query and add the necessary char $ at the
            % willing position
            incomplete_query =  jsonencode(struct_to_convert,"PrettyPrint",true);
            query_char = convertStringsToChars(incomplete_query);
            query = query_char;
            sz_array_operators = max(size(obj.array_operators));
            for op=1:sz_array_operators
                sz_op = max(size(obj.array_operators{1,op}));
                sz_query = max(size(query));
                incr = 1;
                index_array = [];
                while (incr + sz_op <= sz_query)
                    part_query = query_char(incr : incr+sz_op - 1);
                    if strcmp(obj.array_operators{1,op}, part_query)
                        index_array(end+1) = incr;
                    end
                    incr = incr + 1;
                end
                for ind=index_array
                    query = strcat(query_char(1:ind), '$', query_char(ind+1:sz_query)); 
                end
                query_char = query;
            end
        end
    end
end

