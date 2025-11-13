from MongoDBManagement import MongoDBManagement

# Replace by Mongo DB database parameters
hostname = "localhost"
port = 27017
dbname = "CAD"
collection_name = 'files'

# Replace by sftp parameters if the CAD are stored remotely
sftpHost = 'localhost'
sftpPort = 2000
uname = 'sftpuser'
pwd = 'SFTP789'

# Don't modify this
server_conn_components = {
    "sftpHost": sftpHost,
    "sftpPort": sftpPort,
    "uname": uname,
    "pwd": pwd
}

# Create the object to communicate with the database
mongo_db_object = MongoDBManagement(mongo_hostname=hostname, mongo_port=port, mongo_dbname=dbname)

# DB reading Datas from the databases
query = {"tags": "Pipes"}
found_docs = mongo_db_object.find_data_in_database(query=query, collection=collection_name)
print(found_docs)

# DB writing
doc = {"originDatabase": "Fabwave", "tags": ["Pipes"], "fileDirectory": "D:\CAD files\Fabwave\CAD16-24\Pipes\STL",
       "filename": "0a79f67b-2028-46e7-899d-7c134f29079f.stl"}

# Upload the documents in the database
mongo_db_object.upload_documents_to_db(doc, dir_name=collection_name)