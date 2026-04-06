clear all
set more off
cap log close

* Specify directories here
global root "...\Saline Township"
global dta "...\Saline Township\data"
global dta0 "...\data"
global results "...\Saline Township\results"

set scheme plotplain
**********************************************
*    Count raw property number by proximity  *
**********************************************
*Count residential properties
use "$dta\WASHTENAW_RawProperties_withDistance.dta",replace
drop if Ag==1
drop if dist_WashSolar >= 6  /* consider 1 mi radius to the outline of the project - hard to measure since the project polygon is complicated */
drop if SITUSSTREETADDRESS==""
duplicates drop SITUSSTREETADDRESS PARCELLEVELLATITUDE PARCELLEVELLONGITUDE,force

gen I = 1
egen Prop_count = sum(I)
replace I=. 
replace I = 1 if dist_WashSolar<1
egen Prop_count_1mi = sum(I)
replace I=. 
replace I = 1 if dist_WashSolar<2
egen Prop_count_2mi = sum(I)
replace I=. 
replace I = 1 if dist_WashSolar<2.5
egen Prop_count_2p5mi = sum(I)
replace I=. 
replace I = 1 if dist_WashSolar<3
egen Prop_count_3mi = sum(I)
replace I=. 
replace I = 1 if dist_WashSolar<4
egen Prop_count_4mi = sum(I)
keep Prop_count Prop_count_1mi Prop_count_2mi Prop_count_2p5mi Prop_count_3mi Prop_count_4mi 
ren Prop_count Prop_count_6mi

duplicates drop
tab Prop_count_1mi
tab Prop_count_2mi
tab Prop_count_2p5mi
tab Prop_count_3mi
tab Prop_count_4mi
tab Prop_count_6mi

/*


. tab Prop_count_1mi

Prop_count_ |
        1mi |      Freq.     Percent        Cum.
------------+-----------------------------------
        228 |          1      100.00      100.00
------------+-----------------------------------
      Total |          1      100.00

. tab Prop_count_2mi

Prop_count_ |
        2mi |      Freq.     Percent        Cum.
------------+-----------------------------------
        758 |          1      100.00      100.00
------------+-----------------------------------
      Total |          1      100.00

. tab Prop_count_2p5mi

Prop_count_ |
      2p5mi |      Freq.     Percent        Cum.
------------+-----------------------------------
       1023 |          1      100.00      100.00
------------+-----------------------------------
      Total |          1      100.00

. tab Prop_count_3mi

Prop_count_ |
        3mi |      Freq.     Percent        Cum.
------------+-----------------------------------
       2008 |          1      100.00      100.00
------------+-----------------------------------
      Total |          1      100.00

. tab Prop_count_4mi

Prop_count_ |
        4mi |      Freq.     Percent        Cum.
------------+-----------------------------------
       4779 |          1      100.00      100.00
------------+-----------------------------------
      Total |          1      100.00

. tab Prop_count_6mi

Prop_count_ |
        6mi |      Freq.     Percent        Cum.
------------+-----------------------------------
      12717 |          1      100.00      100.00
------------+-----------------------------------
      Total |          1      100.00

*/

******************************************************************
*    Estimate Total Impact with raw Properties in three counties  *
******************************************************************

*Estimate total impact on residential properties
use "$dta\WASHTENAW_RawProperties_withDistance.dta",replace
drop if Ag==1
drop if dist_WashSolar >= 6 
drop if SITUSSTREETADDRESS==""
duplicates drop SITUSSTREETADDRESS PARCELLEVELLATITUDE PARCELLEVELLONGITUDE,force

*Sum stats on market value of homes in the community
sum MARKETTOTALVALUE, d
_pctile MARKETTOTALVALUE, p(67 80 90)
return list
display r(r1)
*Market Value Distribution
count if MARKETTOTALVALUE >= 1000000

* 1. Full distribution (all values)
histogram MARKETTOTALVALUE, ///
    frequency /// or percent if you prefer
    color(navy%70) ///
    lcolor(white) ///
    width(50000) /// adjust bin width as needed
    title("Market Total Value – Full Distribution (6 mi radius)") ///
    subtitle("All Properties") ///
    xtitle("Market Total Value ($)") ///
    ytitle("Number of Properties") saving("$results\hist_marketvalue_full.gph", replace)
graph export "$results\hist_marketvalue_full.png", replace width(2000) height(1400)

histogram MARKETTOTALVALUE, ///
    frequency /// or percent if you prefer
    color(navy%70) ///
    lcolor(white) ///
    width(50000) /// adjust bin width as needed
    title("Market Total Value – Full Distribution (6 mi radius)") ///
    subtitle("All Properties") ///
    xtitle("Market Total Value ($)") ///
    ytitle("Number of Properties") saving("$results\hist_marketvalue_full.gph", replace)
graph export "$results\hist_marketvalue_full.png", replace width(2000) height(1400)

* 2. Zoomed-in version: only properties < $1,000,000
histogram MARKETTOTALVALUE if MARKETTOTALVALUE < 1000000, ///
    frequency ///
	xline(400000) ///
    color(cranberry%70) ///
    lcolor(white) ///
    width(25000) /// smaller bins for better detail
    title("Market Total Value – Properties < $1 Million (6 mi radius)") ///
    subtitle("Excludes high-value outliers") ///
    xtitle("Market Total Value ($)") ///
    ytitle("Number of Properties") ///
    note("67th percentile is about $400k")
graph export "$results\hist_marketvalue_under1M.png", replace width(2000) height(1400)

histogram MARKETTOTALVALUE if dist_WashSolar<2.5, ///
    frequency /// or percent if you prefer
    color(navy%70) ///
    lcolor(white) ///
    width(50000) /// adjust bin width as needed
    title("Market Total Value – Full Distribution (2.5 mi radius)") ///
    subtitle("All Properties") ///
    xtitle("Market Total Value ($)") ///
    ytitle("Number of Properties")
graph export "$results\hist_marketvalue_full_2p5mi.png", replace width(2000) height(1400)

*Impact on annualized home value
gen valueimpact = .0659*MARKETTOTALVALUE*.05 
*Coefficient from average impact estimates

*Calculate total impacts on annualized impact
gen I =0 
replace I = 1 if  dist_WashSolar<1
egen totalImpact_1mi_PerY = total(valueimpact*I) 
egen totalPropNum_1mi = total(I)

replace I=0
replace I = 1 if  dist_WashSolar<2
egen totalImpact_2mi_PerY = total(valueimpact*I)
egen totalPropNum_2mi = total(I)

replace I=0
replace I = 1 if  dist_WashSolar<2.5
egen totalImpact_2p5mi_PerY = total(valueimpact*I)
egen totalPropNum_2p5mi = total(I)


*Total Impact Analysis
local years  = 10
* Discount rates
local r1 = 0.07   // 7%
local r2 = 0.05   // 5%

* NPV formula for annuity due (first cash flow today = 10 payments)
* NPV = Annual × [1 + (1 – (1+r)^(-9))/r ] - when cash flow starts immediately

gen NPV_7pct_1mi   = totalImpact_1mi_PerY   * (1 + (1 - (1 + `r1')^(-(`years'-1))) / `r1')
gen NPV_5pct_1mi   = totalImpact_1mi_PerY   * (1 + (1 - (1 + `r2')^(-(`years'-1))) / `r2')
gen NPV_7pct_2p5mi  = totalImpact_2p5mi_PerY * (1 + (1 - (1 + `r1')^(-(`years'-1))) / `r1')
gen NPV_5pct_2p5mi   = totalImpact_2p5mi_PerY * (1 + (1 - (1 + `r2')^(-(`years'-1))) / `r2')

keep NPV_* totalImpact_1mi_PerY totalImpact_2p5mi_PerY totalPropNum_1mi totalPropNum_2p5mi
keep in 1

* Add descriptive variable labels
label var NPV_7pct_1mi   "NPV @ 7% – 1-mile ring"
label var NPV_5pct_1mi   "NPV @ 5% – 1-mile ring"
label var NPV_7pct_2p5mi "NPV @ 7% – 2.5-mile ring"
label var NPV_5pct_2p5mi "NPV @ 5% – 2.5-mile ring"
label var totalImpact_1mi_PerY   "Annualized Loss – 1-mile ring"
label var totalImpact_2p5mi_PerY "Annualized Loss – 2.5-mile ring"
label var totalPropNum_1mi "Total Number of Residential Properties – 1-mile ring"
label var totalPropNum_2p5mi "Total Number of Residential Properties – 2.5-mile ring"

* Transpose so it becomes a nice 4×2 table
xpose, clear varname

* Create readable row names
gen Radius   = ""
gen Discount_Rate     = ""
replace Radius = "1 mile"    if _n==1 |_n==2|_n==5 | _n==6
replace Radius = "2.5 miles" if _n==3 |_n==4 | _n==7|_n==8
replace Discount_Rate   = "7%" if _n==5 | _n==7
replace Discount_Rate   = "5%" if _n==6 | _n==8

gen Value = v1
format Value %15.0fc

gen No_Residences = 228 if Radius=="1 mile"
replace No_Residences = 1023 if Radius=="2.5 miles"

ren _varname Name
drop if _n==2|_n==4
replace Name="Annualized Loss" if _n==1 |_n==2
replace Name="NPV for loss in 10 years" if _n>2

keep Name Radius Discount_Rate Value No_Residences
order Name Radius Discount_Rate Value No_Residences

* Final table (you'll see this in Stata)
list, clean noobs

* Export to CSV
export delimited using "$results\Total_Impact_NPV_Summary.csv", replace




****************************************************************************************************
*    Estimate Total Impact with raw Properties only in washtenaw county and the saline township    *
****************************************************************************************************

*Estimate total impact on residential properties
use "$dta\WASHTENAW_RawProperties_withDistance.dta",replace
drop if Ag==1
drop if dist_WashSolar >= 6  /* consider 1 mi radius to the outline of the project - hard to measure since the project polygon is complicated */
drop if SITUSSTREETADDRESS==""
duplicates drop SITUSSTREETADDRESS PARCELLEVELLATITUDE PARCELLEVELLONGITUDE,force

*Impact on annualized home value
gen valueimpact = .0659*MARKETTOTALVALUE*.05

*Calculate total impacts on annualized impact
gen I =0 
replace I = 1 if  dist_WashSolar<1
egen totalImpact_1mi_PerY = total(valueimpact*I), by(SITUSCOUNTY)
egen totalPropNum_1mi = total(I), by(SITUSCOUNTY)

replace I=0
replace I = 1 if  dist_WashSolar<2
egen totalImpact_2mi_PerY = total(valueimpact*I), by(SITUSCOUNTY)
egen totalPropNum_2mi = total(I), by(SITUSCOUNTY)

replace I=0
replace I = 1 if  dist_WashSolar<2.5
egen totalImpact_2p5mi_PerY = total(valueimpact*I), by(SITUSCOUNTY)
egen totalPropNum_2p5mi = total(I), by(SITUSCOUNTY)


*Total Impact Analysis
local years  = 10
* Discount rates
local r1 = 0.07   // 7%
local r2 = 0.05   // 5%


gen NPV_7pct_1mi   = totalImpact_1mi_PerY   * (1 + (1 - (1 + `r1')^(-(`years'-1))) / `r1')
gen NPV_5pct_1mi   = totalImpact_1mi_PerY   * (1 + (1 - (1 + `r2')^(-(`years'-1))) / `r2')
gen NPV_7pct_2p5mi  = totalImpact_2p5mi_PerY * (1 + (1 - (1 + `r1')^(-(`years'-1))) / `r1')
gen NPV_5pct_2p5mi   = totalImpact_2p5mi_PerY * (1 + (1 - (1 + `r2')^(-(`years'-1))) / `r2')

keep NPV_* totalImpact_1mi_PerY totalImpact_2p5mi_PerY totalPropNum_1mi totalPropNum_2p5mi SITUSCOUNTY
duplicates drop

* Add descriptive variable labels

label var NPV_7pct_1mi   "NPV @ 7% – 1-mile ring"
label var NPV_5pct_1mi   "NPV @ 5% – 1-mile ring"
label var NPV_7pct_2p5mi "NPV @ 7% – 2.5-mile ring"
label var NPV_5pct_2p5mi "NPV @ 5% – 2.5-mile ring"
label var totalImpact_1mi_PerY   "Annualized Loss – 1-mile ring"
label var totalImpact_2p5mi_PerY "Annualized Loss – 2.5-mile ring"
label var totalPropNum_1mi "Total Number of Residential Properties – 1-mile ring"
label var totalPropNum_2p5mi "Total Number of Residential Properties – 2.5-mile ring"

* Export to CSV
export delimited using "$results\Total_Impact_NPV_Summary_bycounty.csv", replace

