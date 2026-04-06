
# In[1]:


# Measuring planned Washtenaw solar proximity with properties# Created on: 2025-11-17
# Description:
# ---------------------------------------------------------------------------
# Set the necessary product code
# import arcinfo

#import system modules
import arcpy
from arcpy import env
from arcpy.sa import *
import os
import time
import sys

#Set workspace
env.workspace = r"...\\SolarSite.gdb"
gdb = r"...\Washtenaw_Project.gdb"
#Check SA extension license
arcpy.CheckOutExtension("Spatial")

#Define roots/directories
root=r"...\Saline Township"
outputroot=root+"\\data"

#Define properties
properties = outputroot+"\\Saline_Properties.csv"
property_GIS=gdb+"\\Saline_Properties"

#Define names for Solar sites or other significant geographic features
Plannedsite_GIS = gdb+"\\WashtenawSolar"

StartTime0=time.process_time()
#Property
sr = arcpy.Describe(r"....gdb\Prop_location").spatialReference
arcpy.management.Delete(property_GIS, "")
arcpy.management.XYTableToPoint(properties, property_GIS, "PARCELLEVELLONGITUDE", "PARCELLEVELLATITUDE","", sr)

#Output
outfile1 = outputroot+"\\RawProperty_Dist_WashSolar.txt"

arcpy.management.Delete(outfile1, "")

#ag property's distance from transmission lines(in m)
arcpy.analysis.GenerateNearTable(property_GIS,Plannedsite_GIS,outfile1,'','NO_LOCATION','ANGLE','ALL',1,'GEODESIC')
StopTime1=time.process_time()
elapsedTime=(StopTime1-StartTime0)
print ('Time for operating is: '+ str(round(elapsedTime / 60, 1))+ ' mins')


"""
After all these, find the distances in outfile1
"""

