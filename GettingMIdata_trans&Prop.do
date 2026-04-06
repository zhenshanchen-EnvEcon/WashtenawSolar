clear all
set more off
cap log close

* Specify directories here
global root "...\Saline Township"
global dta "...\Saline Township\data"
global dta0 "...\data"
global results "...\Saline Township\results"


*Get Properties with sales for MI 
use "...\CoreLogicProp_All_Analysis_Update_b5.dta", clear
keep if SITUSSTATE=="MI"
*keep if SITUSCOUNTY=="MUSKEGON"|SITUSCOUNTY=="OCEANA"
save "$dta\MI_Sales.dta",replace

*Get raw property data (assessment) for MI - already done with CoreLogic data for 2024 assessment
*use "...\CoreLogic_CurAss_SFR_AG_MI.dta", clear

*************************************************************************
*    Get Transaction data for Washtenaw County & Neighboring Counties   *
*************************************************************************

use "$dta\MI_Sales.dta",clear
keep if SITUSCOUNTY=="WASHTENAW"|SITUSCOUNTY=="LENAWEE"|SITUSCOUNTY=="MONROE"
tab SITUSCOUNTY
save "$dta\WASHTENAW_Properties_wSales.dta",replace
export delimited using "$dta\WASHTENAW_Properties_wSales.csv", replace
*Turn to ArcGIS to measure distance with the planned solar site

*********************************************************
*    Get Distance from Washtenaw Solar to Properties    *
*********************************************************
import delimited using "$dta\PropertyWSales_Dist_WashSolar.txt", delimiter(",") clear
keep in_fid near_dist 
ren near_dist dist_WashSolar
replace dist_WashSolar = dist_WashSolar/1609.34  /*change to miles*/
save "$dta\PropertyWSales_Dist_WashSolar.dta",replace

use "$dta\WASHTENAW_Properties_wSales.dta", clear
gen in_fid = _n
merge 1:1 in_fid using"$dta\PropertyWSales_Dist_WashSolar.dta",keepusing(dist_WashSolar)
drop if _merge==1
drop _merge
save "$dta\WASHTENAW_Properties_withDistance.dta",replace
*This is used to calculated numbers of properties with sales within X miles (in data_process.do)


**********************************************************************
*   Get Assessment data for Washtenaw County & Neighboring Counties  *
**********************************************************************
use "...\CoreLogic_CurAss_SFR_AG_MI.dta",clear
keep if SITUSCOUNTY=="WASHTENAW"|SITUSCOUNTY=="LENAWEE"|SITUSCOUNTY=="MONROE"
tab SITUSCOUNTY
save "$dta\CoreLogic_CurAss_SFR_AG_WASHTENAW.dta",replace
keep TOWNSHIP FIPSCODE PARCELLEVELLATITUDE PARCELLEVELLONGITUDE COMPOSITEPROPERTYLINKAGEKEY SITUSSTREETADDRESS
export delimited using "$dta\CoreLogic_CurAss_SFR_AG_WASHTENAW.csv", replace
*Turn to ArcGIS to measure distance with the planned solar site

import delimited using "$dta\RawProperty_Dist_WashSolar.txt", delimiter(",") clear
keep in_fid near_dist 
ren near_dist dist_WashSolar
replace dist_WashSolar = dist_WashSolar/1609.34  /*change to miles*/
save "$dta\RawProperty_Dist_WashSolar.dta",replace

use "$dta\CoreLogic_CurAss_SFR_AG_WASHTENAW.dta", clear
gen in_fid = _n
merge 1:1 in_fid using"$dta\RawProperty_Dist_WashSolar.dta",keepusing(dist_WashSolar)
drop if _merge==1
drop _merge
save "$dta\WASHTENAW_RawProperties_withDistance.dta",replace
hist dist_WashSolar
*This is passed to Total_Impact_Estimate (in Total_Impact_Estimate.do)

