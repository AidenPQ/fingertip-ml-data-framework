%% Main: Update Boundaries in Database
clear variables
close all
clc

dbstop if error
addpath 'jsonfiles'
addpath fingerbase_data\
addpath hop_automatic_fingertip_design_objects\

%% Connect to database (change the appropriate database name dbname)
server = "localhost";
port = 27017;
dbname = "CAD";
conn = mongoc(server,port,dbname);

%% List of Collections
collection = "files";


%% Compute Boundaries (if new databases, compute the boundaries of the CAD and add new field boundaries to the datas)
update_boundaries = AddBoundariesLimitsToDataInDB(conn, collection);
docs = update_boundaries.list_documents;
boundaries = update_boundaries.list_documents_and_boundaries;
update_boundaries.updateBoundariesInDB();


%% Define search Query (For a more complex database, it will need to learn how to write a query from scratch)

queryManager = QueryManager();

% Define a simple struture with one field (change fieldname and value
% according to what you search

search_struct.tags = "Pipes";

% If you want to load documents that respect the conditions for multiples
% tags values and don't have any consideration in the order of this tags

search_struct1.tags = struct("all", ["Pipes" "Mechanical component"]);

% If you want to load documents that have at least one of the given tags in
% paremeters here is the form:

search_struct2.tags = struct("in", ["Pipes" "Mechanical component"]);

query = queryManager.convert_from_struct_to_query(search_struct);
query1 = queryManager.convert_from_struct_to_query(search_struct1);
query2 = queryManager.convert_from_struct_to_query(search_struct2);


%% Import Data when stored locally

data_import = ImportData();

data = data_import.import_from_one_collection(conn, collection, Query=query);


%% Automate Positionning

% pc_filename = "D:\CAD files\Fabwave\CAD16-24\Pipe_Fittings\STL\exammodelsankuranubhav0.stl";

aut_pos = AutomatePositionning();

% Name of the json genrated file
jsonfile_name = "Test";

% position_steps.indv_transf_steps_orientation = [[0 0 0], [0 0 -90]];
% position_steps.indv_transf_steps_translation = [[0 0 -1], [0 0 0]];
% 
% aut_pos.json_operation_gen("pipe3", pc_filename, position_steps=position_steps);

aut_pos.json_operation_gen(jsonfile_name, data);




