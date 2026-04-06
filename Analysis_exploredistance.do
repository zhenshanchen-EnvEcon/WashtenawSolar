clear all
set more off
cap log close

* Specify directories here
global root "...\Saline Township"
global dta "...\Saline Township\data"
global dta0 "...\data"
global results "...\Saline Township\results"

set scheme plotplain

**************************
*  Import property data  *
**************************
use "$dta0\data_b5_foranalysis_....dta",clear	// Specify source data - 1,106,078 obs

* Merge with selected sites *
drop near_fid
gen near_order=.

foreach n in 1 2 3 4 5 {
	ren near_fid`n' fid
	replace fid=9999 if fid==.
	merge m:1 fid using"$dta\similar_sites_to_WashtenawSolar_Filtered.dta", keepusing(rank) update 
	drop if _merge==2
	replace near_order=`n' if (_merge==3 | (_merge==4 & near_order==.))
	drop _merge
	ren fid near_fid`n'
}

drop if rank==.          // 277,219 obs left
drop if near_order!=1    // 91,188 obs left
tab rank

*drop outliers - already conducted in previous data processing

drop if e_Year<2000     
duplicates report 
save "$dta\data_b5_foranalysis_Saline_Filtered.dta",replace


*****************************
*      Explore Distance     *
* Effects up to 3.5 miles as done previously
*****************************
global House_X "c.logDistRoad#i.post  c.logDistMetro#i.post c.TotalBedrooms#i.post c.TotalCalculatedBathCount#i.post c.BuildingAge#i.post c.BuildingAge_sq#i.post  c.NoofFirePlace#i.post"
global House_CAT "i.Aircondition#i.post i.Heated#i.post i.BuildingCondition#i.post i.Garage#i.post i.Pool#i.post i.FuelType#i.post i.SewerType#i.post"

use "$dta\data_b5_foranalysis_Saline_Filtered.dta",clear
global House_X0 "logDistLine post_logDistLine logDistRoad  logDistMetro"
foreach v in $House_X0 {
	sum `v'
	replace `v' = r(mean) if `v'==.
}

*drop if near_dist_solar1>6

global control=6
egen State=group(state)
egen locale=group(Tract)
capture drop cty
egen cty = group(state county)

est clear

*Generate distance decay measures - segregate into rings
cap drop ring

gen ring=0
	replace ring=0 if near_dist_solar1<=1
	
	count if near_dist_solar1<=1 &post==1
	di r(N)

mat CNT=J(1,3,.)
foreach d of numlist 0(50)550 {
	*treatment term
	replace ring=(`d')/10 if near_dist_solar1>((`d')/100) & near_dist_solar1<=(`d'+50)/100
	count if near_dist_solar1>((`d')/100) & near_dist_solar1<=(`d'+50)/100 &post==1
	di r(N)  " in (`d')/100 to (`d'+50)/100"
	mat CNT=(CNT\r(N),`d'/100,(`d'+50)/100)
	*interaction term
}
replace ring=60 if near_dist_solar1>4
drop if near_dist_solar1>6
*di r(N) 
mat list CNT

foreach d of numlist 1(.5)6 {
	count if near_dist_solar1>`d' & near_dist_solar1<`d'+.5 & post==1
	di "# of post observations in the ring `d' (+.5 mi) is:" r(N)  
}

*Distance Decay
est clear
*
reghdfe logSalesPrice 1.post ib60.ring ib60.ring#1.post logDistLine post_logDistLine $House_X if near_dist_solar1<=6,  a(i.cty#i.e_Year i.locale) cluster(locale e_Year)
est sto distdecay_study
esttab using "$results\distdecay_study_ResiHome_b5_3.5mi.csv", replace 

mat list e(b)
*mat list e(V)

mat A=J(1,4,.)

forv n=11(1)17  {

	di e(b)[1,`n']
	di sqrt(e(V)[`n',`n'])
	
	scalar lb1=e(b)[1,`n']-1.96*sqrt(e(V)[`n',`n'])
	scalar ub1=e(b)[1,`n']+1.96*sqrt(e(V)[`n',`n'])
	
	mat A=(A\e(b)[1,`n'],sqrt(e(V)[`n',`n']),lb1,ub1)
}
mat list A

clear
svmat A

ren A1 mean
drop if A2==.
gen ring=(_n-1)/2

twoway ///
    (connected mean ring, lp(solid) lcolor(blue) lwidth(medium)) ///
	(rarea A3 A4 ring, lcolor(blue%1) color(blue%15)), ///
    legend( label(1 "Point Estimate") label(2 "95% CI") position(5) ring(0) c(1) r(4)) ///
    xtitle("Distance (in miles)") xlabel(0 "[0,0.5)" 0.5 "[0.5,1)" 1 "[1,1.5)" 1.5 "[1.5,2)" 2 "[2,2.5)" 2.5 "[2.5,3)" 3 "[3,3.5)"  ) ///
    ytitle("Effect on Natural Logarithm of Home Price") yline(0) ysc(range(-0.12 0.05)) ylabel(-0.15 -0.1 -0.05 0 0.05)

graph export "$results\DistanceDecay_3.5mi.png", as(png) replace
graph export "$results\DistanceDecay_3.5mi.pdf", as(pdf) replace
















