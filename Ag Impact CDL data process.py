
import arcpy
from arcpy import env
from arcpy.sa import *
import os

# Set workspace (adjust to your environment)
env.workspace = r"...\SalineTownship_WashtenawSolar.gdb"  # Change this to your workspace path
env.overwriteOutput = True
root=r"...\Saline Township"
outputroot=root+"\\data"

# Input file paths (adjust these to your actual file paths)
solar_fc = env.workspace + "\\WashtenawSolar"  # Shapefile of the solar polygon
county_fc = env.workspace + "\\ThreeCounties_WashtenawSolar"  # Shapefile of the county boundary
township_fc = env.workspace + "\\SalineTownship"  # Shapefile of the county boundary
cdl_raster = env.workspace + "\\c2024_10mcdls_3Cty"  # 10m CDL raster clipped to county

# Ensure spatial analyst extension is checked out
arcpy.CheckOutExtension("Spatial")

# Output tables for tabulation
solar_table = outputroot + "\\solar_cdl_tabulate.dbf"
county_table = outputroot + "\\county_cdl_tabulate.dbf"
township_table = outputroot + "\\salinetownship_cdl_tabulate.dbf"

# Zone field: assuming OBJECTID is the unique identifier; adjust if needed
zone_field = "OBJECTID"

# Step 2 & 4: Tabulate areas for crop types within solar site and county
# This creates tables with zones (OBJECTID) and VALUE (CDL class code) columns, plus AREA
print("Running Tabulate Area for solar site...")
arcpy.sa.TabulateArea(solar_fc, zone_field, cdl_raster, "VALUE", solar_table)

print("Running Tabulate Area for county...")
arcpy.sa.TabulateArea(county_fc, zone_field, cdl_raster, "VALUE", county_table)

print("Running Tabulate Area for saline township...")
arcpy.sa.TabulateArea(township_fc, zone_field, cdl_raster, "VALUE", township_table)

