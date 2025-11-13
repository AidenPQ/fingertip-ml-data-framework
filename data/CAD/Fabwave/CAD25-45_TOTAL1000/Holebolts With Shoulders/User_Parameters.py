import adsk.core, adsk.fusion, traceback
import uuid

def run(context):
    ui = None
    try:
        app = adsk.core.Application.get()
        ui  = app.userInterface
        
        design = app.activeProduct
        rootComp = design.rootComponent
        
        
        # Read the csv file.
        cnt = 0

        #Write your own file location in the box
        file = open(r'D:\\NCSU\\Fall 2019\\ISE 589 DM\\userparam1.csv')
        for line in file:
            # Get the values from the csv file.
            pieces = line.split(',')
            
            eyeInnerDia = pieces[9]
            eyeOuterDia = pieces[10]
            shankLength = pieces[0]
            threadDia = pieces[4]
            totalLength = pieces[3]
            #shoulderLength = pieces[8]
                        
                       
            # Set the parameters.
            eyeInnerParam = rootComp.modelParameters.itemByName('d1')
            eyeInnerParam.expression = eyeInnerDia

            eyeOuterParam = rootComp.modelParameters.itemByName('d2')
            eyeOuterParam.expression = eyeOuterDia
          
            shankLengthParam = rootComp.modelParameters.itemByName('d30')
            shankLengthParam.expression = shankLength

            threadDiaParam = rootComp.modelParameters.itemByName('d31')
            threadDiaParam.expression = threadDia

            totalLengthParam = rootComp.modelParameters.itemByName('d28')
            totalLengthParam.expression = totalLength

            #shoulderLengthParam = rootComp.modelParameters.itemByName('d25')
            #shoulderLengthParam.expression = shoulderLength

            
            
            #Export the STEP file.
            exportMgr = design.exportManager
	    
            filename = uuid.uuid4()

	        #Write your own file location in the box
            stepOptions = exportMgr.createSTEPExportOptions("D:\\NCSU\\Fall 2019\\ISE 589 DM\\UserParam\\" + str(filename) + '.stp')
            res = exportMgr.execute(stepOptions)

            fusionArchiveOptions = exportMgr.createFusionArchiveExportOptions("D:\\NCSU\\Fall 2019\\ISE 589 DM\\UserParam\\" + str(filename) + '.f3d')
            res2 = exportMgr.execute(fusionArchiveOptions)

            stlOptions = exportMgr.createSTLExportOptions(rootComp, "D:\\NCSU\\Fall 2019\\ISE 589 DM\\UserParam\\" + str(filename) + '.stl')
            stlOptions.sendToPrintUtility = False
            res1 = exportMgr.execute(stlOptions)

            #save as image file
            app.activeViewport.fit()
            app.activeViewport.saveAsImageFile("D:\\NCSU\\Fall 2019\\ISE 589 DM\\UserParam\\"+str(filename)+'.jpg', 0, 0)  
            #if cnt > 5:
            #    break
            cnt += 1
       
        ui.messageBox('Finished: ' +  str(cnt) + ' Models Generated')
    except:
        if ui:
            ui.messageBox('Failed:\n{}'.format(traceback.format_exc()))