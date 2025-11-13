%% Update path
clear variables
close all
clc

dbstop if error
addpath 'jsonfiles'
addpath fingerbase_data\
addpath hop_automatic_fingertip_design_objects\
addpath downloadCAD\

%% Connect to database and sftp user (Change server and port to the appropriate server IP and port and database name dbname)
server = "";
port = 27017;
dbname = "dbSTL";
conn = mongoc(server,port,dbname);

sftp_user = ""; % to complete
server_ip = "serverIP:Port"; % change serverIP and Port
password_to_sftp_user = ""; % to complete

sftp_conn = sftp(server_ip, sftp_user, "Password", password);

%% List of Collections
collection = "Datas";


%% Compute Boundaries (if new databases, compute the boundaries of the CAD and add new field boundaries to the datas)
% update_boundaries = AddBoundariesLimitsToDataInDB(conn, collection);
% docs = update_boundaries.list_documents;
% boundaries = update_boundaries.list_documents_and_boundaries;
% update_boundaries.updateBoundariesInDB();


%% Define search Query (For a more complex database, it will need to learn how to write a query from scratch)

queryManager = QueryManager();

% Define a simple struture with one field (change fieldname and value
% according to what you search

search_struct.fieldname = value;

%If in the database, the field correspond to a single value
%Or if the field correspond to an array and you want to load the datas where the elements in value are find in the specific you wrote them

% query = queryManager.convert_struct_to_simple_query(search_struct);

%If value is an array, and you want to load datas where the field have at
%least one of the element of value as it value (Best for tags search)

query = queryManager.convert_one_field_struct_to_at_least_one_element_query(search_struct);

% More complex Queries

%% Import Data when stored remotely

data_import = ImportDataLocal();

datas = data_import.import_from_one_collection(conn, collection, Query=query);

for doc = datas
    folder = cd(sftp_conn, doc.fileDirectory);
    downloadpath = mget(sftp_conn, doc.filename, "downloadCAD\");
end

%% Automate Positionning
aut_pos = AutomatePositionning();

