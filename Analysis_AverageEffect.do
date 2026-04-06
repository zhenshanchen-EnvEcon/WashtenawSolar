clear all
set more off
cap log close

* Specify directories here
global root "...\Saline Township"
global dta "...\Saline Township\data"
global dta0 "...\data"
global results "...\Saline Township\results"

set scheme plotplain

****************************
*      Average Effect      *
****************************
global House_X "c.logDistRoad#i.post  c.logDistMetro#i.post c.TotalBedrooms#i.post c.TotalCalculatedBathCount#i.post c.BuildingAge#i.post c.BuildingAge_sq#i.post  c.NoofFirePlace#i.post"
global House_CAT "i.Aircondition#i.post i.Heated#i.post i.BuildingCondition#i.post i.Garage#i.post i.Pool#i.post i.FuelType#i.post i.SewerType#i.post"

use "$dta\data_b5_foranalysis_Saline_Filtered.dta",clear
global House_X0 "logDistLine post_logDistLine logDistRoad  logDistMetro"
foreach v in $House_X0 {
	sum `v'
	replace `v' = r(mean) if `v'==.
}

egen State=group(state)
egen locale=group(Tract)
capture drop cty
egen cty = group(state county)

global control=6
global treat=2.5 /* 2.5mi treatment definition based on distance decay metrics */
drop if (near_dist_solar1<$treat+1) & (near_dist_solar1>$treat)
drop if (near_dist_solar1>6)

*treatment term
replace solar1T=0
replace solar1T=1 if near_dist_solar1<=$treat

count if near_dist_solar1 < 1

gen highvalue=(SalesPrice>400000)
*Main - Separate
*
reghdfe logSalesPrice 1.solar1T 1.post 1.solar1T#1.post logDistLine post_logDistLine $House_X $House_CAT,  a(i.cty#i.e_Year i.locale) cluster(cty e_Year)
est sto DID_ResiHome

reghdfe logSalesPrice 1.solar1T 1.post 1.highvalue 1.solar1T#1.post#1.highvalue 1.solar1T#1.post#0.highvalue logDistLine post_logDistLine $House_X $House_CAT,  a(i.cty#i.e_Year i.locale) cluster(cty e_Year)
est sto DID_ResiHome_highlow

*Combine Estimates
esttab DID_ResiHome DID_ResiHome_highlow using "$results/Main_results.tex",replace b(a3) se mti("DID Proximity") keep(1.solar1T 1.solar1T#1.post 1.solar1T#1.post#1.highvalue 1.solar1T#1.post#0.highvalue) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab DID_ResiHome DID_ResiHome_highlow using "$results/Main_results.csv",replace b(a3) se mti("DID Proximity") keep(1.solar1T 1.solar1T#1.post 1.solar1T#1.post#1.highvalue 1.solar1T#1.post#0.highvalue) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab DID_ResiHome DID_ResiHome_highlow using "$results/Main_results_all.csv",replace b(a3) se mti("DID Proximity") star(+ 0.10 * 0.05 ** 0.01 *** 0.001)




********************************************************************************
*           Event Study - Resi Home - Proximity as treatment   Figure 3        *
********************************************************************************
use "$dta\data_b5_foranalysis_Saline_Filtered.dta",clear
global House_X0 "logDistLine post_logDistLine logDistRoad  logDistMetro"
foreach v in $House_X0 {
	sum `v'
	replace `v' = r(mean) if `v'==.
}

egen State=group(state)
egen locale=group(Tract)
capture drop cty
egen cty = group(state county)

global control=6
global treat=2.5
drop if (near_dist_solar1<$treat+1) & (near_dist_solar1>$treat)
drop if (near_dist_solar1>6)

*Generate Event Study years
gen Year_event=Year_relative+10
drop if Year_relative>10
drop if Year_event<3

global control=6
global treat=2.5
drop if (near_dist_solar1<$treat+1) & (near_dist_solar1>$treat)
drop if (near_dist_solar1>6)

*treatment term
replace solar1T=0
replace solar1T=1 if near_dist_solar1<=$treat

est clear
drop if (near_dist_solar1<$treat+1) & (near_dist_solar1>$treat)
drop if (near_dist_solar1>6)

*regression on  property less than 5 acres, prior1 as base
reghdfe logSalesPrice 1.solar1T ib9.Year_event ib9.Year_event#1.solar1T logDistLine post_logDistLine $House_X if Year_event>=0 , a(i.cty#i.e_Year i.locale) cluster(cty e_Year)
eststo event_study_Resi_p3
*mat list e(b)
*mat list e(V)
parmest, saving("$results\event_study_Resi_results.dta", replace)

use "$results\event_study_Resi_results.dta", clear
keep in 21/36

* Generate a numeric variable for the yearcategories
gen year = _n
destring year, replace

* Create variables for the confidence intervals
gen ci_low = min95
gen ci_high = max95

*
twoway (rarea ci_low ci_high year, lcolor(orange%1) color(orange%10) ysc(range(-0.12 0.05))) ///
       (connected estimate year, mcolor(blue) ysc(range(-0.12 0.05))), ///
       xlabel(1 " prior year 6" 2 "prior year 5" 3 "prior year 4" 4 "prior year 3" 5"prior year 2" 6"prior year 1" 7"year 0" 8"year 1" 9"year 2" 10"year 3" 11 "year 4" 12"year 5" 13 "year 6" 14 "year 7" 15 "year 8" 16 "year 9" ,angle(45)) ///
    legend(label(1 "95% CI Event study") label(2 "Point Estimates")  position(2) ring(0)) ///
    ytitle("Effect on Natural Logarithm of Home Price") xtitle(Year) ///
	xline(6, lw(vthin) lc(red)) ///
    yline(0, lw(thin) lcolor(grey)) ylabel(-.2 -0.15 -0.1 -0.05 0 0.05 0.1) ysc(range(-0.15 0.1))
	
graph export "$results\ResHomeb5_eventstudy_Proxy.png",as(png) replace
graph export "$results\ResHomeb5_eventstudy_Proxy.pdf",as(pdf) replace


