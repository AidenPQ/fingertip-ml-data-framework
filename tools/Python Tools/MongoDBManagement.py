import os
import pysftp
from pymongo import MongoClient


# The structure of the repartition should be so that the folders' name in this should be the name of the original database

CAD_root_directory = "D:\\CAD files"   # Root directory where are stored all CAD are stored

# Original Database name (Complete with more names when new CADs are added from other sources
databases_name = ["Fabwave"]

# Base on Fabwave list
components_list = ['Bearings', 'Bolts', 'Brackets', 'Bushing', 'Bushing_Damping_Liners', 'Collets', 'Gasket',
                   'Grommets', 'HeadlessScrews', 'Hex_Head_Screws', 'Keyway_Shaft', 'Machine_Key', 'Nuts', 'O_Rings',
                   'Thumb_Screws', 'Pipes', 'Pipe_Fittings', 'Pipe_Joints', 'Rollers', 'Rotary_Shaft', 'Shaft_Collar',
                   'Slotted_Flat_Head_Screws', 'Socket_Head_Screws', 'Washers']


doc_form = {"originDatabase": "", "tags": [], "fileDirectory": "", "filename": ""}


class MongoDBManagement:
    
    def __init__(self, mongo_hostname, mongo_port, mongo_dbname):
        self.mongo_db = self.mongo_conn(hstname=mongo_hostname, prt=mongo_port, db=mongo_dbname)

    def mongo_conn(self, hstname, prt, db):
        try:
            conn = MongoClient(host=hstname, port=prt)
            print("MongoDB connected", conn)
            return conn[db]
        except Exception as e:
            print("Error in mongo connection", e)

    def create_document_to_upload(self, original_database, file_directory, filename, tags):
        doc = {"originDatabase": original_database, "tags": tags, "fileDirectory": file_directory, "filename": filename}
        return doc

    def create_tags_for_document(self, actual_dir):
        tags = []
        source_database = ""
        for i in range(len(databases_name)):
            if actual_dir.find(databases_name[i]) != -1:
                source_database = databases_name[i]
        if source_database == "Fabwave":  # Add specificities to your tags (in this case for Fabwave they are sorted by their names)
            for i in range(len(components_list)):
                if actual_dir.find(components_list[i]) != -1:
                    tags.append(components_list[i])
                    tags.append("Mechanical Components")
        return tags, source_database

    def create_all_documents_for_local_storage_case(self):
        documents = []
        list_folder_path = [CAD_root_directory]

        while len(list_folder_path) != 0:
            actual_dir = list_folder_path.pop(0)
            list_directories = os.listdir(actual_dir)

            for e in list_directories:
                e_path = actual_dir + "\\" + e
                if os.path.isdir(e_path) and e != "STEP":
                    list_folder_path.append(e_path)
                elif e.endswith(".stl"):
                    tags, source_database = self.create_tags_for_document(actual_dir=actual_dir)
                    doc = self.create_document_to_upload(source_database, actual_dir, e, tags)
                    documents.append(doc)
        return documents

    def create_all_documents_for_remote_storage_case(self, sftp_host, sftp_port, uname, pwd):
        documents = []
        list_dir = [CAD_root_directory]

        cn_opts = pysftp.CnOpts()
        cn_opts.hostkeys = None

        # sftp connection for remote testing to obtain the list of files to upload
        with pysftp.Connection(host=sftp_host, port=sftp_port, username=uname, password=pwd, cnopts=cn_opts) as sftp:
            while len(list_dir) != 0:
                actual_dir = list_dir.pop(0)
                sftp.cwd(remotepath=actual_dir)
                list_directories = sftp.listdir()

                for e in list_directories:
                    e_path = actual_dir + "\\" + e
                    if sftp.isdir(e_path) and e != "STEP":
                        list_directories.append(e_path)
                    elif e.endswith(".stl"):
                        tags, source_database = self.create_tags_for_document(actual_dir=actual_dir)
                        doc = self.create_document_to_upload(source_database, actual_dir, e, tags)
                        documents.append(doc)
        sftp.close()
        return documents

    def upload_documents_to_db(self, posts, dir_name):
        collection = self.mongo_db[dir_name]
        if type(posts) == list:
            try:
                ins = collection.insert_many(posts)
                print("All documents have been inserted", ins)
            except Exception as e:
                print("Error in mongo connection", e)
        else:
            try:
                ins = collection.insert_one(posts)
                print("The document has been inserted", ins)
            except Exception as e:
                print("Error in mongo connection", e)

    def find_data_in_database(self, query, collection, fields_to_include={}, isremote=False, localpathtodownload="", server_conn_components={}):
        results = []
        for doc in self.mongo_db[collection].find(query, fields_to_include):
            results.append(doc)
        if isremote:
            cn_opts = pysftp.CnOpts()
            cn_opts.hostkeys = None

            with pysftp.Connection(host=server_conn_components["sftpHost"], port=server_conn_components["sftpPort"], username=server_conn_components["uname"], password=server_conn_components["pwd"], cnopts=cn_opts) as sftp:
                for res in results:
                    file_remote_path = res["fileDirectory"] + "/" + res["filename"]
                    if sftp.isfile(file_remote_path):
                        sftp.get(remotepath=file_remote_path, localpath=localpathtodownload)
        return results

    def initialize_database(self, collection, dir_name, islocal=True):
        if islocal:
            posts = self.create_all_documents_for_local_storage_case()
        else:
            posts = self.create_all_documents_for_remote_storage_case()
        for post in posts:
            if len(self.mongo_db[collection].find(post)) == 0:
                self.upload_documents_to_db(posts=post, dir_name=dir_name)



