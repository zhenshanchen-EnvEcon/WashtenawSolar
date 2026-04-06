# WashtenawSolar
This is the replication package for report submitted to Saline Township: "Property Value and Agricultural Impact Assessment: Washtenaw Solar Project". Files include Python code (.py) and Stata code (.do) files. The Python code files are used to run GIS analysis with ArcPy functions, and the Stata code are used to preprocess data and run final analyses. 
1. data_process.do preprocesses the datasets, gets data ready for GIS analysis, and merges the GIS attributes back to generate a list of solar sites (existing in USPVDB https://energy.usgs.gov/uspvdb/) that are similar to the proposed site - Washtenaw Solar.
2. Analysis_exploredistance.do explores spatial extent of the property value impact from solar sites, with property transactions around solar sites in the list. 
3. Analysis_AverageEffect.do explores average property value impact.
4. GettingMIdata_trans&Prop.do acquires data to run the analyses and the total impact estimate for properties around the proposed site.
5. Total_Impact_Estimate.do conducts the total impact estimate for properties around the proposed site.
6. Agri_Impact.do analyzes Cropland Data Layer (CDL) data and estimates the proposed site's impact on land acreage in farms and total market value of farm products.
7. Merge_tract.py merges solar sites with census tracts to get the census tract statistics (i.e., median income in this case) for all solar sites involved.  
8. MeasuringDistance_Properties.py measures the distance from properties to the proposed solar site.
9. Measure_Distance_from_Metro_Areas.py measures the distance from solar sites to certain geographic features (i.e., nearest distance to major metro areas as an example)
10. Ag_Impact_CDL_data_process.py processes CDL data for the agricultural impact analysis (in Agri_Impact.do).
