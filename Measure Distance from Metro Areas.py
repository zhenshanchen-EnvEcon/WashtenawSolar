# Measuring Distance from Solar Sites to major metropolitan area
# 

#import system modules
import arcpy
from arcpy import env
from arcpy.sa import *
import os
import time
import sys

# Set workspace (adjust to your environment)
env.workspace = r"...\SalineTownship_WashtenawSolar.gdb"  # Change this to your workspace path
env.overwriteOutput = True
root=r"...\Saline Township"
outputroot=root+"\\data"
#Check SA extension license
arcpy.CheckOutExtension("Spatial")

#Define names for Solar sites or other significant geographic features
    #Metropolitan area
metropolitan = env.workspace+"\\Midwest_Major_Metro"
USPVDB_site = r"...\uspv\uspvdb_v3_0_20250430.shp"

StartTime0=time.process_time()

sr = arcpy.Describe(r"...\SolarSite_View.gdb\Prop_location").spatialReference
#arcpy.management.Delete(property_GIS, "")
#arcpy.management.XYTableToPoint(properties, property_GIS, "PARCELLEVELLONGITUDE", "PARCELLEVELLATITUDE","", sr)

outfile4 = outputroot+"\\NearDist_USPVDB25_Majormetro_Midwest.txt"

arcpy.management.Delete(outfile4, "")
 

StopTime3=time.process_time()
#ag property's distance from metropolitan (in m)
arcpy.analysis.GenerateNearTable(USPVDB_site,metropolitan,outfile4,'','NO_LOCATION','NO_ANGLE','CLOSEST',1,'GEODESIC')
StopTime4=time.process_time()
elapsedTime=(StopTime4-StopTime3)
print ('Time for operating is: '+ str(round(elapsedTime / 60, 1))+ ' mins')

"""
After all these, find the distances in outfile1: outputroot+"\\NearDist_....txt"
"""

