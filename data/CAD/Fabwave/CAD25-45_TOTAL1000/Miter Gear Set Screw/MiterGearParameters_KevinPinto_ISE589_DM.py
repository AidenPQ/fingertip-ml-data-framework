#Author-
#Description-

import adsk.core, adsk.fusion, adsk.cam, traceback, uuid, csv

def run(context):
    ui = None
    try:
        app = adsk.core.Application.get()
        ui  = app.userInterface
        design = app.activeProduct
        rootComp = design.rootComponent

        #Directory of where the CSV File is 
        csvLoc = "C:\\Users\\kpinto\\Desktop\\Miter Gear Set Screw_KevinPinto\\Raw Data\\"  
        #Directory of where information will need to be saved
        finalLoc = "C:\\Users\\kpinto\\Desktop\\Miter Gear Set Screw_KevinPinto\\"

        file = open(csvLoc + "DataParameters.csv")
        cnt = 1
        
        des = adsk.fusion.Design.cast(app.activeProduct)
        userParams = des.userParameters
    
        #Open CSV File and read information
        with open(csvLoc + "DataParameters.csv") as csv_file:  
            csv_reader = csv.reader(csv_file, delimiter=',')
            next(csv_reader) #skip headers (Row 1)
    
            for line in csv_reader:
            
                #splitting each line and assigning element to appropriate variables
            
                pitch = line[0]
                numteeth = line[1]
                pressureangle = line[2]
                pitch_dia = line[3]
                od = line[4]
                face_width = line[5]
                overallwd = line[6]
                shaftdia = line[7].strip('"')
                hubdia = line[10]
                hubwidth = line[11]
                keywd = line[12]
                keydp = (line[13])
                

                #Set the parameters in the Fusion file as per information on the CSV file

                userParams.itemByName('gear1teeth').expression =  numteeth
                userParams.itemByName('pitchdia').expression =  pitch_dia
                userParams.itemByName('od').expression =  od
                userParams.itemByName('facewidth').expression =  face_width
                userParams.itemByName('overallwd').expression =  overallwd
                userParams.itemByName('hubdia').expression =  hubdia
                userParams.itemByName('hubwidth').expression =  hubwidth
                userParams.itemByName('keywd').expression =  keywd
                userParams.itemByName('keydp').expression =  keydp
                userParams.itemByName('shaftdia').expression =  shaftdia
                userParams.itemByName('pressureangle').expression =  pressureangle
                userParams.itemByName('pitch').expression =  pitch


                #Create a UUID filename - Unique Identifier
                filename = uuid.uuid4()

                #Export to a .STEP file
                exportMgr = design.exportManager
                stpOptions = exportMgr.createSTEPExportOptions(finalLoc+ 'STEP\\'+str(filename)+".stp")
                exportMgr.execute(stpOptions)

                #Create an Image Files 
                app.activeViewport.fit()
                app.activeViewport.saveAsImageFile(finalLoc+ 'JPEG\\'+str(filename)+'.jpg',0,0)

                #Create an STL Files 
                exportMgr = design.exportManager
                stlOptions = exportMgr.createSTLExportOptions(rootComp)
                stlOptions.filename = finalLoc+'STL\\'+str(filename)+".stl"
                exportMgr.execute(stlOptions)

                #F3D
                exportMgr = design.exportManager
                f3dOptions = exportMgr.createFusionArchiveExportOptions(finalLoc+'F3D\\'+str(filename)+".f3d")
                #f3dOptions.filename = finalLoc+'F3D\\'+str(filename)+".f3d"
                exportMgr.execute(f3dOptions)

                #Document Counter
                cnt = cnt + 1

            #give a message to the user 
            ui.messageBox("Finished Exporting " + str(cnt)+ " Models")


    except:
        if ui:
            ui.messageBox('Failed:\n{}'.format(traceback.format_exc()))