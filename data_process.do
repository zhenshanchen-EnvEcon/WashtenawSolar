clear all
set more off
cap log close

*Specify directories here
global root "...\Saline Township"
global dta "...\Saline Township\data"
global dta0 "...\data"
global results "...\Saline Township\results"


* Data acquisition and process necessary variables

*States that are in MISO and also Midwest states close to MI (7 states):
*Illinois, Indiana, Iowa, Michigan, Minnesota, Missouri, and Wisconsin
/*
use "$dta0\data_b5_foranalysis_final_final1.dta", clear  
*More property vars than PNAS data
tab state
keep if state=="IL" | state=="IN" | state=="IA" | state=="MI" | state=="MN" | state=="MO" | state=="WI"
ren SITUSCITY city
save "$dta\data_b5_foranalysis_Saline.dta",replace
*/

******************
*  Get the sites *
******************
use "$dta0\data_b5_foranalysis_Saline.dta",clear
keep state county city address near_fid* near_dist_solar* 
drop near_fid
duplicates drop
sort *
duplicates drop state county city address,force
save "$dta0\Propertyb5_site_Saline.dta",replace

**************************************************************
*    Count properties with sales within 5 miles and 1 mile   *
**************************************************************
foreach n in 1 2 3 4 5 {
	use "$dta0\Propertyb5_site_Saline.dta",clear
	keep state county city address near_fid`n' near_dist_solar`n' 
	ren near_fid`n' fid
	duplicates drop
	duplicates report state county city address  /*LatFixed LongFixed*/
	di r(unique_value)
	drop if near_dist_solar`n' >= 5
	gen I = 1
	egen Prop_count = sum(I), by(fid)
	replace I=. 
	replace I = 1 if near_dist_solar`n'<1
	egen Prop_count_1mi = sum(I), by(fid)
	replace I=.
	replace I = 1 if near_dist_solar`n'<2
	egen Prop_count_2mi = sum(I), by(fid)
	keep Prop_count Prop_count_1mi Prop_count_2mi fid
    duplicates drop
	save "$dta0\Salinedata_b5_propcount_near`n'.dta",replace
}

use "$dta0\Salinedata_b5_propcount_near1.dta",clear
gen order=1
foreach n in 2 3 4 5 {
	append using "$dta0\Salinedata_b5_propcount_near`n'.dta"
	replace order=`n' if order==.
}

egen Prop_count_all=sum(Prop_count), by(fid)
egen Prop_count_all_1mi=sum(Prop_count_1mi), by(fid)
egen Prop_count_all_2mi=sum(Prop_count_2mi), by(fid)
keep fid Prop_count_all Prop_count_all_1mi Prop_count_all_2mi
duplicates drop
distinct fid
sort fid
save "$dta0\Salinedata_site_propcount.dta",replace

*Solar Site Data
import dbase "$dta0\uspvdbSHP\uspvdb_v1_0_20231108.dbf", clear
gen fid = _n-1
save "$dta0\solar_sites\solar_sites.dta",replace

use "$dta0\solar_sites\solar_sites.dta", clear
merge 1:1 fid using"$dta0\Salinedata_site_propcount.dta"
keep if _merge==3
drop _merge
replace Prop_count_all=0 if Prop_count_all==.

drop if p_type!="greenfield"
keep if p_cap_ac>=5
save "$dta0\Salinedata_site_final.dta",replace
*107 utility-scale solar sites in the midwest
egen totalprop=sum(Prop_count_all_1mi)
di totalprop
*In total - 12,105 properties within 1 mi before further filtering the sites

*If needs further filtering, the fid will be identifier for property sample filter.
use "$dta0\Salinedata_site_final.dta",clear
export delimited using "$dta0\Salinedata_site_final.csv", replace
*export into ArcGIS to measure distances & other, the gdb feature class has the same name 



*********************************************************
*        Combine Site data with GIS attributes          *
*********************************************************
*GIS attributes are processed in Python with ArcPy functions

*Add census tract and corresponding income
capture import delimited "$dta\Saline_sites_tract.txt", delimiter(",") clear
drop fid_censustracts mtfcc funcstat intptlat intptlon
tostring geoid, replace format(%11.0f)
duplicates report p_state p_county geoid name
ren fid_salinedata_site_final in_fid
save "$dta\Saline_sites_tract.dta",replace

*Add median household income of the census tract based on the most recent 5-year ACS data
import excel "$dta\Saline_sites_TractIncome.xlsx", sheet("Sheet1") firstrow clear
ren GEOID geoid 
ren NAME name
duplicates report p_state p_county geoid name
tostring geoid, replace format(%11.0f)
save "$dta\Saline_sites_TractIncome.dta",replace

use "$dta\Saline_sites_tract.dta",clear
merge 1:1 p_name p_state p_county geoid name using"$dta\Saline_sites_TractIncome.dta"
drop _merge
sort p_state p_county geoid name
save "$dta\Saline_sites_tractWincome.dta",replace

*Calculate population trends - population estimates from Census
import excel "$dta\County_pop_trend.xlsx", sheet("Sheet1") firstrow clear
ren County p_county
ren State p_state
ren Census pop_2020
ren Estimate estpop_2024
ren Change Perc_change
replace Perc_change = Perc_change*100
save "$dta\County_pop_trend.dta",replace

*County FIPS
import delimited "$dta\State_County_and_City_FIPS_Reference_Table_20251124.csv", clear 
drop cityname stcntyfipscode citycode stcntycityfipscode
duplicates drop
ren statecode p_state
ren countyname p_county
tostring statefipscode, replace 
gen FIPS_str = statefipscode+subinstr(countycode,"C","",.)
destring FIPS_str, generate(FIPS)
save "$dta\county_FIPS.dta",replace


*Add distance to metropolitan areas 
capture import delimited "$dta\NearDist_SalineSite_Majormetro_Midwest.txt", delimiter(",") clear
drop objectid
ren near_dist near_dist_majormetro
label variable near_dist_majormetro "near_dist_majormetro"
replace near_dist_majormetro = near_dist_majormetro/1609.34  /*change to miles*/
save "$dta\Saline_sites_DistMetro.dta",replace


use "$dta\Salinedata_site_final.dta",clear
set type double
gen in_fid=_n

capture drop _merge
merge 1:1 in_fid using"$dta\Saline_sites_tractWincome.dta",keepusing(median_household_income)
drop if _merge==1
drop _merge

capture drop _merge
merge 1:1 in_fid using"$dta\Saline_sites_DistMetro.dta",keepusing(near_dist_majormetro)
drop if _merge==1
drop _merge

capture drop _merge
merge m:1 p_state p_county using"$dta\County_pop_trend.dta",keepusing(Perc_change)
drop if _merge==1
drop if _merge==2
drop _merge
ren Perc_change Pop_change_perc

replace p_county = upper(p_county)
replace p_county="LA SALLE" if p_county=="LASALLE"
replace p_county="LA SALLE" if p_county=="LASALLE"
replace p_county="ST JOSEPH" if p_county=="ST. JOSEPH"

joinby p_state p_county using "$dta\county_FIPS.dta", unm(m)
tab _merge
drop _merge

ren p_year e_Year
merge m:1 FIPS e_Year using "$dta\presvoteshare_county.dta", keepusing(FIPS percDEM)
drop if _merge==2
drop _merge
ren e_Year p_year

save "$dta\Salinedata_site_final_wAttr.dta",replace
*export delimited using "$dta\Salinedata_site_final_wAttr.csv", replace


*****************************************************************************
*            Load and Find Relevant Data - Washtenaw Solar                  *
*****************************************************************************

use "$dta\county_FIPS.dta", clear
keep if p_county == "WASHTENAW"

* County population (Washentaw not available)
use "$dta\County_pop_trend.dta", clear
keep if p_county == "Washtenaw" // 0 obs

* Import Census Bureau Population Data by Counties
import excel "$dta\cb_est_pop_MI_counties_clean.xlsx", firstrow clear
gen Pop_change = (jul1_2024 / jul1_2020)
gen Pop_change_dec = (jul1_2024 / jul1_2020) - 1
gen Pop_change_perc = ((jul1_2024 / jul1_2020) - 1) * 100
save "$dta\cb_est_pop_MI_counties_clean.dta",replace

* Percentage Democrat
use "$dta\presvoteshare_county.dta", clear
keep if FIPS == 26161


**********************************************************************
*             Add Washtenaw Solar Data to Site List                  *
**********************************************************************

* Load dataset of EXISTING sites
use "$dta\Salinedata_site_final_wAttr.dta", clear

* Add one more observation (for Washtenaw Solar)
set obs `= _N +1'

* Fill in the values for this new observations*/
replace case_id = 999999 in `=_N'

* From FIPS data
replace p_state = "MI" in `=_N'
replace p_county = "WASHTENAW" in `=_N'
replace statename = "MICHIGAN" in `=_N'
replace statefipscode = "26" in `=_N'
replace countycode = "C161" in `=_N'
replace FIPS_str = "26161" in `=_N'
replace FIPS = 26161 in `=_N'

* From WASHTENAW_Properties_withDistance.dta tabulation
replace Prop_count_all = 1098 in `=_N' // properties within 6mi
replace Prop_count_all_1mi = 36 in `=_N'
replace Prop_count_all_2mi = 158 in `=_N'

* From presvoteshare_county.dta (2020 election)
replace percDEM = .7260764 in `=_N'

* From cb_est_pop_MI_counties_clean.dta (Population growth % (2020–2024))
replace Pop_change_perc = .5448448 in `=_N'

* From Census Bureau Quick Facts: (https://www.census.gov/quickfacts/fact/table/salinecitymichigan/PST045224)
replace median_household_income = 88346 in `=_N' // Median households income (in 2024 dollars), 2020-2024


* SITE CHARACTERISTICS 
replace p_name = "Washtenaw Solar" in `=_N'
replace p_year = 2026 in `=_N'
replace p_pwr_reg = "MISO" in `=_N'
replace p_type = "greenfield" in `=_N'
replace near_dist_majormetro = 1.99 in `=_N'

* SITE CHARACTERISTICS (from website: https://washtenawsolar.invenergy.com/)
replace p_cap_ac = 150 in `=_N' // no differentiation between AC and DC power
replace p_battery = "missing" in `=_N' // no mention of a battery anywhere


* Save the new, completed site attributes dataset
save "$dta\Washtenaw_Solar_final_wAttr.dta", replace

* Save just the Washtenaw Solar details
keep if p_name == "Washtenaw Solar"
save "$dta\just_Washtenaw_Solar_wAttr.dta", replace




***************************************************
*           Calculating Similarity Score          *
***************************************************

* 1. Load existing and planned sites
use "$dta\Washtenaw_Solar_final_wAttr.dta", clear
replace p_county=upper(p_county)

keep if !missing(p_cap_ac, p_battery, Prop_count_all, Prop_count_all_1mi, ///
                Pop_change_perc, median_household_income, percDEM, ///
				near_dist_majormetro)

* 2. Generate new variables and drop necessary sites

gen proposed = 1 if p_name == "Washtenaw Solar"
replace proposed = 0 if p_name != "Washtenaw Solar"

gen battery = 1 if p_battery=="batteries" /* Too many missing values in p_battery*/
replace battery=0 if battery==.

gen p_MI = 1 if p_state == "MI"     /* Binary indicator for Michigan solar site */
replace p_MI = 0 if p_MI ==.

tab Prop_count_all_2mi if p_cap_ac>50
drop if Prop_count_all_2mi <30               // 25 obs dropped 
drop if near_dist_majormetro==0

* 3. Set X variables

********************************************************************************
*  FIND MOST SIMILAR EXISTING SOLAR SITES TO A PLANNED SITE
*  Attributes used:
*    p_cap_ac                – AC capacity (MW)
*    Prop_count_all          – Total parcels/properties in area
*    Prop_count_all_1mi      – Parcels within 1 mile (land availability proxy)
*    Pop_change_perc         – Population growth % (2020–2024)
*    median_household_income – Median income in census tract/block group
*    percDEM                 - Percent that voted Democrat in 2020 presidential election
*    near_dist_majormetro    - Distance (mi) from solar site to major MW metro area (e.g., Detroit, Chicago)
*    p_MI                    - Binary indicator = 1 if the site is in Michigan
********************************************************************************

global X p_cap_ac Prop_count_all Prop_count_all_1mi Pop_change_perc median_household_income percDEM near_dist_majormetro p_MI

* Not included this round due to too many missing values in original data: 
*    p_battery               – Battery capacity (MW or MWh – treated as numeric)

* 4. Standardize all variables (zero mean, unit variance) – crucial for fair distance
* Generate an ID: existing sites = original _n, planned site = last observation 
* (different from existing site id-fid)
gen long site_id = _n
local N_existing = _N - 1
local planned_id = _N

foreach x in $X {
	summarize `x'            if site_id <= `N_existing'
	gen double z_`x'         = (`x'            - r(mean)) / r(sd)
}

* 5. Optional: Apply weights (most people weight capacity & income high)
gen double w_cap_ac     = z_p_cap_ac     * 2     // AC capacity matters
gen double w_prop_all   = z_Prop_count_all  * .5
gen double w_prop_1mi   = z_Prop_count_all_1mi  * .5
gen double w_pop_change = z_Pop_change_perc * 1  
gen double w_income     = z_median_household_income     * 1     // income drives potential cost & opposition
gen double w_percDEM     = z_percDEM    * 3     // political leaning strongly drives cost & opposition
gen double w_dist_metro  = z_near_dist_majormetro	* 3  // urban interface matters 
gen double w_p_MI        = z_p_MI	* 3  // Michigan has a unique regulatory environment

* 6. Calculate squared Euclidean distance from the planned site
gen double sqdist = .
replace sqdist = (w_cap_ac     - w_cap_ac[`planned_id'])^2     + ///
    (w_prop_all   - w_prop_all[`planned_id'])^2   + ///
    (w_prop_1mi   - w_prop_1mi[`planned_id'])^2   + ///
    (w_pop_change - w_pop_change[`planned_id'])^2 + ///
    (w_income     - w_income[`planned_id'])^2 + ///
	(w_percDEM     - w_percDEM[`planned_id'])^2 + ///
	(w_dist_metro  - w_dist_metro[`planned_id'])^2 + ///
	(w_p_MI        - w_p_MI[`planned_id'])^2

* Take square root to get actual (weighted) Euclidean distance
gen double distance = sqrt(sqdist)
gsort distance

gen rank = _n-1
save "$dta\similar_sites_to_WashtenawSolar_ranked.dta", replace

use "$dta\similar_sites_to_WashtenawSolar_ranked.dta",clear
* Decide how many sites to include - based on total properties within 1 mi
drop if rank==0
gen totalprop_1mi_cum = sum(Prop_count_all_1mi)
gen totalprop_6mi_cum = sum(Prop_count_all)

keep if rank <=29  /*Targetting 4000 treated observations*/ 
* criteria: total properties within 1 mi exceeds 4000, ensuring enough data for within 1 mi effect identification
* total within 5mi exceeds 85k.
save "$dta\similar_sites_to_WashtenawSolar_Filtered.dta", replace
export delimited using "$dta\similar_sites_to_WashtenawSolar_Filtered.csv", replace

use "$dta\similar_sites_to_WashtenawSolar_Filtered.dta",clear
append using "$dta\just_Washtenaw_Solar_wAttr.dta"
replace rank = 0 if p_name == "Washtenaw Solar"

drop in_fid p_cap_dc near_dist_water p_area 
drop z_* w_* sqdist site_id battery statename statefips countycode FIPS_str p_zscore fid visibility near_dist_river near_dist_majorlake ln_dist_water p_img_date p_dig_conf

ren Prop_count_all NProp_withsale_6mi
ren Prop_count_all_* NProp_withsale_*
global X p_name p_year p_cap_ac NProp_withsale_1mi NProp_withsale_2mi NProp_withsale_6mi p_state p_county case_id eia_id ylat xlong p_pwr_reg  p_type p_agrivolt
order $X
export delimited using "$results\Similarsites_to_WashtenawSolar_Filtered_Washtenawin.csv", replace
export delimited using "$dta\Similarsites_to_WashtenawSolar_Filtered_Washtenawin.csv", replace

sum p_cap_ac if rank!=0, d


