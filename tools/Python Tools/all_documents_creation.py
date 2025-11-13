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

# Create the documents if the CAD are stored locally
docs = mongo_db_object.create_all_documents_for_local_storage_case()

print(docs)
