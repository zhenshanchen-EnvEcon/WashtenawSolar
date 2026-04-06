#!/usr/bin/env python

# Intersecting solar sites with census tracts - for Washtenaw solar property value evaluation

# Created on: 2025-11-17
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

#setup parallel processing
arcpy.env.parallelProcessingFactor = "75%"  # Use 50% of available cores
#Set workspace
gdb = r"...\Washtenaw_Project.gdb"

#Check SA extension license
arcpy.CheckOutExtension("Spatial")
env.workspace=gdb

#Define roots
#root=r"...\\Saline Township"
#outputroot=root+"\\GIS"

Tract_shape = r"...\CensusTract\CensusTracts.shp"

properties = outputroot+"\\Saline_Properties.csv"
property_GIS=gdb+"\\Saline_Properties"

#Property
sr = arcpy.Describe(r"....gdb\Prop_location").spatialReference
arcpy.management.Delete(property_GIS, "")
arcpy.management.XYTableToPoint(properties, property_GIS, "PARCELLEVELLONGITUDE", "PARCELLEVELLATITUDE","", sr)

Input_prop=property_GIS

Site_tract=gdb+"\\WRTdata_site_tract"

StartTime2=time.process_time()
# Process: Intersect property with positive view raster
arcpy.management.Delete(Prop_tract,"")
arcpy.analysis.Intersect(Input_prop+" #;"+Tract_shape+" #", Site_tract, "ALL", "", "INPUT")

out_table = r"...\data\Saline_sites_tract.txt"
arcpy.conversion.ExportTable(
    in_table=Site_tract,
    out_table=out_table,
    where_clause="",
    field_mapping=""
)
StopTime2=time.process_time()
elapsedTime2=(StopTime2-StartTime2)
print('Time for intersect properties with census tracts '+' is: '+ str(round(elapsedTime2, 1))+ ' seconds')

