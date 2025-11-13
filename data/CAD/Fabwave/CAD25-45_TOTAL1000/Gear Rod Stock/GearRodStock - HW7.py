
#Author-swagata-Ghazaal
#Description-

import adsk.core, adsk.fusion, adsk.cam, traceback
import uuid
import math

def run(context):
    ui = None
    try:
        app = adsk.core.Application.get()
        ui  = app.userInterface
        design = app.activeProduct
        rootComp = adsk.fusion.Component.cast(design.rootComponent)
        exportMgr = adsk.fusion.ExportManager.cast(design.exportManager)
        

    
        csvLoc = "D:\\ISE589\\"
        finalLoc = "F:\\ISE589-HW7\\"

        file = csvLoc
        file = open (csvLoc + "DataParameter.csv")
        
        cnt = 1
        for line in file:
            values = line.split(',')

            #splitting each line into l, w, h
            teethnumber = values[0]
            pitchdiameter = values[1]
            outsidediameter = values[2]
            shaftdiameter = values[3]
            pitch = values[4]

            #create list of each parameter
            teethnumberParam = rootComp.modelParameters.itemByName('t')
            pitchdiameterParam = rootComp.modelParameters.itemByName('d')
            outsidediameterParam = rootComp.modelParameters.itemByName('d2')
            shaftdiameterParam = rootComp.modelParameters.itemByName('d1')
            pitchParam = rootComp.modelParameters.itemByName('32')
            

            #link the list to know what you need to extract from fusion
            teethnumberParam.expression = teethnumber 
            pitchdiameterParam.expression = pitchdiameter
            outsidediameterParam.expression = outsidediameter
            shaftdiameterParam.expression = shaftdiameter
            
            
            
            #create a UUID filename- Unique Identifier 
            filename = uuid.uuid4()

            #export to a .step file (std codes available in fusion)        
            exportMgr = design.exportManager
            stpOptions = exportMgr.createSTEPExportOptions('F:\\ISE589-HW7\\' + str(cnt) + '.stp')
            
            
            #setting the filename
            exportMgr.execute(stpOptions)          

            
            #export to a .f3d  file (std codes available in fusion)        
            fusionArchivevOptions = exportMgr.createFusionArchiveExportOptions("F:\\ISE589-HW7\\" + str(filename) + '.f3d')
            res = exportMgr.execute(fusionArchivevOptions)

            #create the image files
            app.activeViewport.fit()
            app.activeViewport.saveAsImageFile("F:\\ISE589-HW7\\" + str(filename) + '.jpg', 0, 0 )
            
            #create STL file
            stlOptions = exportMgr.createSTLExportOptions(rootComp,"F:\\ISE589-HW7\\" + str(filename) + '.stl')
            exportMgr.execute(stlOptions)
            
            
            
            cnt = cnt + 1
            


        ui.messageBox('Finished! All models have been created!')
    except:
        if ui:
            ui.messageBox('Failed:\n{}'.format(traceback.format_exc()))
