clear all
set more off
cap log close

* Specify directories here
global root "...\Saline Township"
global dta "...\Saline Township\data"
global dta0 "...\data"
global results "...\Saline Township\results"


***Calculate category area in CDL 2024 10m by 10m - CDL raster transformed into shapefile (dbf included) in ArcGIS 
*Solar
import dbase using "$dta\solar_cdl_tabulate.dbf",clear
reshape long VALUE_, i(OBJECTID) j(CATE)
gen value = int(VALUE_)
drop VALUE_

qui {
	label define cdl_legend ///
    0   "Background" ///
    1   "Corn" ///
    2   "Cotton" ///
    3   "Rice" ///
    4   "Sorghum" ///
    5   "Soybeans" ///
    6   "Sunflower" ///
    10  "Peanuts" ///
    11  "Tobacco" ///
    12  "Sweet Corn" ///
    13  "Pop or Orn Corn" ///
    14  "Mint" ///
    21  "Barley" ///
    22  "Durum Wheat" ///
    23  "Spring Wheat" ///
    24  "Winter Wheat" ///
    25  "Other Small Grains" ///
    26  "Dbl Crop WinWht/Soybeans" ///
    27  "Rye" ///
    28  "Oats" ///
    29  "Millet" ///
    30  "Speltz" ///
    31  "Canola" ///
    32  "Flaxseed" ///
    33  "Safflower" ///
    34  "Rape Seed" ///
    35  "Mustard" ///
    36  "Alfalfa" ///
    37  "Other Hay/Non Alfalfa" ///
    38  "Camelina" ///
    39  "Buckwheat" ///
    41  "Sugarbeets" ///
    42  "Dry Beans" ///
    43  "Potatoes" ///
    44  "Other Crops" ///
    45  "Sugarcane" ///
    46  "Sweet Potatoes" ///
    47  "Misc Vegs & Fruits" ///
    48  "Watermelon" ///
    49  "Onions" ///
    50  "Cucumbers" ///
    51  "Chick Peas" ///
    52  "Lentils" ///
    53  "Peas" ///
    54  "Tomatoes" ///
    55  "Caneberries" ///
    56  "Hops" ///
    57  "Herbs" ///
    58  "Clover/Wildflowers" ///
    59  "Sod/Grass Seed" ///
    60  "Switchgrass" ///
    61  "Fallow/Idle Cropland" ///
    63  "Forest" ///
    64  "Shrubland" ///
    65  "Barren" ///
    66  "Cherries" ///
    67  "Peaches" ///
    68  "Apples" ///
    69  "Grapes" ///
    70  "Christmas Trees" ///
    71  "Other Tree Crops" ///
    72  "Citrus" ///
    74  "Pecans" ///
    75  "Almonds" ///
    76  "Walnuts" ///
    77  "Pears" ///
    81  "Pasture/Grass" ///
    82  "Cultivated Hay" ///
    121 "Developed/Open Space" ///
    122 "Developed/Low Intensity" ///
    123 "Developed/Med Intensity" ///
    124 "Developed/High Intensity" ///
    131 "Barren" ///
    141 "Deciduous Forest" ///
    142 "Evergreen Forest" ///
    143 "Mixed Forest" ///
    151 "Shrubland" ///
    152 "Grass/Pasture" ///
    176 "Woody Wetlands" ///
    190 "Herbaceous Wetlands" ///
    195 "Sentinal" ///
    204 "Pistachios" ///
    205 "Triticale" ///
    206 "Carrots" ///
    207 "Asparagus" ///
    208 "Garlic" ///
    209 "Greens" ///
    210 "Plums" ///
    211 "Prunes" ///
    212 "Apricots" ///
    213 "Nectarines" ///
    214 "Pomegranates" ///
    216 "Blueberries" ///
    219 "Olives" ///
    221 "Avocados" ///
    222 "Kiwi" ///
    223 "Dates" ///
    224 "Figs" ///
    225 "Passion Fruit" ///
    226 "Guava" ///
    227 "Papaya" ///
    228 "Mango" ///
    229 "Coffee" ///
    230 "Cacao" ///
    242 "Aquaculture" ///
    243 "Bananas" ///
    244 "Plantains" ///
    245 "Mangoes" ///
    246 "Pineapples" ///
    247 "Taro" ///
    248 "Eggplants" ///
    249 "Gourds" ///
    250 "Cranberries" ///
    254 "Dbl Crop Barley/Soybeans" ///
	998 "Total" ///
    , replace
}


label values CATE cdl_legend
ren value value_sqm
save "$dta\CDL_AreabyCate.dta",replace

*Saline Township
import dbase using "$dta\salinetownship_cdl_tabulate.dbf",clear
reshape long VALUE_, i(OBJECTID) j(CATE)
gen value = int(VALUE_)
drop VALUE_

qui {
	label define cdl_legend ///
    0   "Background" ///
    1   "Corn" ///
    2   "Cotton" ///
    3   "Rice" ///
    4   "Sorghum" ///
    5   "Soybeans" ///
    6   "Sunflower" ///
    10  "Peanuts" ///
    11  "Tobacco" ///
    12  "Sweet Corn" ///
    13  "Pop or Orn Corn" ///
    14  "Mint" ///
    21  "Barley" ///
    22  "Durum Wheat" ///
    23  "Spring Wheat" ///
    24  "Winter Wheat" ///
    25  "Other Small Grains" ///
    26  "Dbl Crop WinWht/Soybeans" ///
    27  "Rye" ///
    28  "Oats" ///
    29  "Millet" ///
    30  "Speltz" ///
    31  "Canola" ///
    32  "Flaxseed" ///
    33  "Safflower" ///
    34  "Rape Seed" ///
    35  "Mustard" ///
    36  "Alfalfa" ///
    37  "Other Hay/Non Alfalfa" ///
    38  "Camelina" ///
    39  "Buckwheat" ///
    41  "Sugarbeets" ///
    42  "Dry Beans" ///
    43  "Potatoes" ///
    44  "Other Crops" ///
    45  "Sugarcane" ///
    46  "Sweet Potatoes" ///
    47  "Misc Vegs & Fruits" ///
    48  "Watermelon" ///
    49  "Onions" ///
    50  "Cucumbers" ///
    51  "Chick Peas" ///
    52  "Lentils" ///
    53  "Peas" ///
    54  "Tomatoes" ///
    55  "Caneberries" ///
    56  "Hops" ///
    57  "Herbs" ///
    58  "Clover/Wildflowers" ///
    59  "Sod/Grass Seed" ///
    60  "Switchgrass" ///
    61  "Fallow/Idle Cropland" ///
    63  "Forest" ///
    64  "Shrubland" ///
    65  "Barren" ///
    66  "Cherries" ///
    67  "Peaches" ///
    68  "Apples" ///
    69  "Grapes" ///
    70  "Christmas Trees" ///
    71  "Other Tree Crops" ///
    72  "Citrus" ///
    74  "Pecans" ///
    75  "Almonds" ///
    76  "Walnuts" ///
    77  "Pears" ///
    81  "Pasture/Grass" ///
    82  "Cultivated Hay" ///
    121 "Developed/Open Space" ///
    122 "Developed/Low Intensity" ///
    123 "Developed/Med Intensity" ///
    124 "Developed/High Intensity" ///
    131 "Barren" ///
    141 "Deciduous Forest" ///
    142 "Evergreen Forest" ///
    143 "Mixed Forest" ///
    151 "Shrubland" ///
    152 "Grass/Pasture" ///
    176 "Woody Wetlands" ///
    190 "Herbaceous Wetlands" ///
    195 "Sentinal" ///
    204 "Pistachios" ///
    205 "Triticale" ///
    206 "Carrots" ///
    207 "Asparagus" ///
    208 "Garlic" ///
    209 "Greens" ///
    210 "Plums" ///
    211 "Prunes" ///
    212 "Apricots" ///
    213 "Nectarines" ///
    214 "Pomegranates" ///
    216 "Blueberries" ///
    219 "Olives" ///
    221 "Avocados" ///
    222 "Kiwi" ///
    223 "Dates" ///
    224 "Figs" ///
    225 "Passion Fruit" ///
    226 "Guava" ///
    227 "Papaya" ///
    228 "Mango" ///
    229 "Coffee" ///
    230 "Cacao" ///
    242 "Aquaculture" ///
    243 "Bananas" ///
    244 "Plantains" ///
    245 "Mangoes" ///
    246 "Pineapples" ///
    247 "Taro" ///
    248 "Eggplants" ///
    249 "Gourds" ///
    250 "Cranberries" ///
    254 "Dbl Crop Barley/Soybeans" ///
	998 "Total" ///
    , replace
}


label values CATE cdl_legend
ren value value_sqm
save "$dta\CDL_AreabyCate_township.dta",replace


import dbase using "$dta\county_cdl_tabulate.dbf",clear
reshape long VALUE_, i(OBJECTID) j(CATE)
recast long VALUE_ 
format VALUE_ %12.0f
gen value = int(VALUE_)
format value %12.0f
drop VALUE_

qui {
	label define cdl_legend ///
    0   "Background" ///
    1   "Corn" ///
    2   "Cotton" ///
    3   "Rice" ///
    4   "Sorghum" ///
    5   "Soybeans" ///
    6   "Sunflower" ///
    10  "Peanuts" ///
    11  "Tobacco" ///
    12  "Sweet Corn" ///
    13  "Pop or Orn Corn" ///
    14  "Mint" ///
    21  "Barley" ///
    22  "Durum Wheat" ///
    23  "Spring Wheat" ///
    24  "Winter Wheat" ///
    25  "Other Small Grains" ///
    26  "Dbl Crop WinWht/Soybeans" ///
    27  "Rye" ///
    28  "Oats" ///
    29  "Millet" ///
    30  "Speltz" ///
    31  "Canola" ///
    32  "Flaxseed" ///
    33  "Safflower" ///
    34  "Rape Seed" ///
    35  "Mustard" ///
    36  "Alfalfa" ///
    37  "Other Hay/Non Alfalfa" ///
    38  "Camelina" ///
    39  "Buckwheat" ///
    41  "Sugarbeets" ///
    42  "Dry Beans" ///
    43  "Potatoes" ///
    44  "Other Crops" ///
    45  "Sugarcane" ///
    46  "Sweet Potatoes" ///
    47  "Misc Vegs & Fruits" ///
    48  "Watermelon" ///
    49  "Onions" ///
    50  "Cucumbers" ///
    51  "Chick Peas" ///
    52  "Lentils" ///
    53  "Peas" ///
    54  "Tomatoes" ///
    55  "Caneberries" ///
    56  "Hops" ///
    57  "Herbs" ///
    58  "Clover/Wildflowers" ///
    59  "Sod/Grass Seed" ///
    60  "Switchgrass" ///
    61  "Fallow/Idle Cropland" ///
    63  "Forest" ///
    64  "Shrubland" ///
    65  "Barren" ///
    66  "Cherries" ///
    67  "Peaches" ///
    68  "Apples" ///
    69  "Grapes" ///
    70  "Christmas Trees" ///
    71  "Other Tree Crops" ///
    72  "Citrus" ///
    74  "Pecans" ///
    75  "Almonds" ///
    76  "Walnuts" ///
    77  "Pears" ///
    81  "Pasture/Grass" ///
    82  "Cultivated Hay" ///
    121 "Developed/Open Space" ///
    122 "Developed/Low Intensity" ///
    123 "Developed/Med Intensity" ///
    124 "Developed/High Intensity" ///
    131 "Barren" ///
    141 "Deciduous Forest" ///
    142 "Evergreen Forest" ///
    143 "Mixed Forest" ///
    151 "Shrubland" ///
    152 "Grass/Pasture" ///
    176 "Woody Wetlands" ///
    190 "Herbaceous Wetlands" ///
    195 "Sentinal" ///
    204 "Pistachios" ///
    205 "Triticale" ///
    206 "Carrots" ///
    207 "Asparagus" ///
    208 "Garlic" ///
    209 "Greens" ///
    210 "Plums" ///
    211 "Prunes" ///
    212 "Apricots" ///
    213 "Nectarines" ///
    214 "Pomegranates" ///
    216 "Blueberries" ///
    219 "Olives" ///
    221 "Avocados" ///
    222 "Kiwi" ///
    223 "Dates" ///
    224 "Figs" ///
    225 "Passion Fruit" ///
    226 "Guava" ///
    227 "Papaya" ///
    228 "Mango" ///
    229 "Coffee" ///
    230 "Cacao" ///
    242 "Aquaculture" ///
    243 "Bananas" ///
    244 "Plantains" ///
    245 "Mangoes" ///
    246 "Pineapples" ///
    247 "Taro" ///
    248 "Eggplants" ///
    249 "Gourds" ///
    250 "Cranberries" ///
    254 "Dbl Crop Barley/Soybeans" ///
	998 "Total" ///
    , replace
}

label values CATE cdl_legend
ren value value_sqm
save "$dta\CDL_AreabyCate_Counties.dta",replace
keep if OBJECTID==3 
save "$dta\CDL_AreabyCate_WASHTENAW.dta",replace

use "$dta\CDL_AreabyCate_WASHTENAW.dta",clear
drop if CATE==0 | (CATE>110 & CATE<130)
*Ag area means undeveloped area 
egen totalarea_sqm=sum(value_sqm)
format totalarea_sqm %12.0f
gen share = value_sqm/totalarea
sort share
gen neg_share = -share
sort neg_share
tab CATE share if share>.01
tab CATE if share>.01
gen ID = _n
preserve
keep if share>.01
keep CATE share
export delimited using "$dta\CDL_AgSharebyCate_WASHTENAWCounty.csv",replace
restore

keep ID CATE value_sqm totalarea_sqm share
order ID
ren value_sqm county_sqm
ren totalarea_sqm countytotarea_sqm
ren share countyshare

merge 1:1 CATE using"$dta\CDL_AreabyCate_township.dta"
drop if _merge==2
drop _merge
drop OBJECTID
egen SalineTWPtotalarea_sqm=sum(value_sqm)
ren value_sqm SalineTWP_sqm
format SalineTWPtotalarea_sqm %12.0f
format SalineTWP_sqm %12.0f

merge 1:1 CATE using"$dta\CDL_AreabyCate.dta"
drop if _merge==2
drop _merge
drop OBJECTID
egen solartotalarea_sqm=sum(value_sqm)
ren value_sqm solar_sqm
gen solarshare_cate = solar_sqm/county_sqm 
gen solarsharetwp_cate = solar_sqm/SalineTWP_sqm

sort ID
gen solar_100sqm = solar_sqm/100
gen solar_ctyperc_catearea = solarshare_cate*100
gen solar_twpperc_catearea = solarsharetwp_cate*100
drop if solar_sqm ==.
gen solar_ctyperc_totarea = 100*solartotalarea_sqm/countytotarea_sqm
gen solar_twpperc_totarea = 100*solartotalarea_sqm/SalineTWPtotalarea_sqm

ren CATE CDL_CATE
keep CDL_CATE countyshare solar_100sqm solar_ctyperc_catearea solar_ctyperc_totarea solar_twpperc_catearea solar_twpperc_totarea
format solar_ctyperc_cate solar_ctyperc_tot %10.2f
save "$dta\CDL_ImpbyCate_WASHTENAW.dta",replace
export delimited using "$dta\CDL_AgSharebyCate_WASHTENAWSolar.csv",replace

*Combine Area Impact with typical value measures to calculate $ value impact

************Available stats ********************
* Gross Income from Ag Census for 2022
* Ag gross income by category - Corn, Soybeans, Wheat, Vegetables, Fruit & Berries, Greenhouse
* Gross income - total crop
* Gross income - total 

/*
2022

Number of farms                                                        1,255
Land in farms (acres)                                            177,064 
Average size of farm (acres)                                        141

Total                                                                    ($)
Market value of products sold                      			  141,322,000
Government payments                                  	      2,549,000
Farm-related income                               	          12,150,000
Total farm production expenses                   			  139,138,000
Net cash farm income                                    	  16,884,000

Per farm average                                                          ($)
Market value of products sold                             		  	 112,607
Government payments 	                                             12,683
Farm-related income 	                                             24,251
Total farm production expenses                           			 110,867
Net cash farm income                                       		     13,453
*/

/*
Sales ($1,000)  
Total                                                                                     141,322

Crops                                                                                     99,610
Grains, oilseeds, dry beans, dry peas                                       71,344 
Tobacco                                                                                 -
Cotton and cottonseed                                                                     -
Vegetables, melons, potatoes, sweet potatoes                                     4,337
Fruits, tree nuts, berries                                                           1,376
Nursery, greenhouse, floriculture, sod                                       13,986 

Cultivated Christmas trees, short rotation
woody crops                                                                         1,352
Other crops and hay                                                                7,214

Livestock, poultry, and products                                        41,712
Poultry and eggs                                                                         604
Cattle and calves                                                                     9,562
Milk from cows                                                                       26,693
Hogs and pigs                                                                          1,076
Sheep, goats, wool, mohair, milk                                             1,981
Horses, ponies, mules, burros, donkeys                                  1,188
Aquaculture                                                                                  (D)
Other animals and animal products                                             (D)
*/

*Cash rent - $84.5 for non-irrigated in 2024

************Estimation Target********************
*Land Acreage total & by category
use "$dta\CDL_ImpbyCate_WASHTENAW.dta",clear
gen neg_solar_100sqm=-(solar_100sqm)
sort neg_solar_100sqm
gen other =(solar_100sqm <10)
egen sum_sqm = sum(solar_100sqm*other)
replace solar_100sqm=solar_100sqm+sum_sqm if CDL_CATE==44
drop if other==1
drop other sum_sqm neg_*
set obs 17
replace CDL_CATE=998 if CDL_CATE==.
qui {
	label define cdl_legend ///
    0   "Background" ///
    1   "Corn" ///
    2   "Cotton" ///
    3   "Rice" ///
    4   "Sorghum" ///
    5   "Soybeans" ///
    6   "Sunflower" ///
    10  "Peanuts" ///
    11  "Tobacco" ///
    12  "Sweet Corn" ///
    13  "Pop or Orn Corn" ///
    14  "Mint" ///
    21  "Barley" ///
    22  "Durum Wheat" ///
    23  "Spring Wheat" ///
    24  "Winter Wheat" ///
    25  "Other Small Grains" ///
    26  "Dbl Crop WinWht/Soybeans" ///
    27  "Rye" ///
    28  "Oats" ///
    29  "Millet" ///
    30  "Speltz" ///
    31  "Canola" ///
    32  "Flaxseed" ///
    33  "Safflower" ///
    34  "Rape Seed" ///
    35  "Mustard" ///
    36  "Alfalfa" ///
    37  "Other Hay/Non Alfalfa" ///
    38  "Camelina" ///
    39  "Buckwheat" ///
    41  "Sugarbeets" ///
    42  "Dry Beans" ///
    43  "Potatoes" ///
    44  "Other Crops" ///
    45  "Sugarcane" ///
    46  "Sweet Potatoes" ///
    47  "Misc Vegs & Fruits" ///
    48  "Watermelon" ///
    49  "Onions" ///
    50  "Cucumbers" ///
    51  "Chick Peas" ///
    52  "Lentils" ///
    53  "Peas" ///
    54  "Tomatoes" ///
    55  "Caneberries" ///
    56  "Hops" ///
    57  "Herbs" ///
    58  "Clover/Wildflowers" ///
    59  "Sod/Grass Seed" ///
    60  "Switchgrass" ///
    61  "Fallow/Idle Cropland" ///
    63  "Forest" ///
    64  "Shrubland" ///
    65  "Barren" ///
    66  "Cherries" ///
    67  "Peaches" ///
    68  "Apples" ///
    69  "Grapes" ///
    70  "Christmas Trees" ///
    71  "Other Tree Crops" ///
    72  "Citrus" ///
    74  "Pecans" ///
    75  "Almonds" ///
    76  "Walnuts" ///
    77  "Pears" ///
    81  "Pasture/Grass" ///
    82  "Cultivated Hay" ///
    121 "Developed/Open Space" ///
    122 "Developed/Low Intensity" ///
    123 "Developed/Med Intensity" ///
    124 "Developed/High Intensity" ///
    131 "Barren" ///
    141 "Deciduous Forest" ///
    142 "Evergreen Forest" ///
    143 "Mixed Forest" ///
    151 "Shrubland" ///
    152 "Grass/Pasture" ///
    176 "Woody Wetlands" ///
    190 "Herbaceous Wetlands" ///
    195 "Sentinal" ///
    204 "Pistachios" ///
    205 "Triticale" ///
    206 "Carrots" ///
    207 "Asparagus" ///
    208 "Garlic" ///
    209 "Greens" ///
    210 "Plums" ///
    211 "Prunes" ///
    212 "Apricots" ///
    213 "Nectarines" ///
    214 "Pomegranates" ///
    216 "Blueberries" ///
    219 "Olives" ///
    221 "Avocados" ///
    222 "Kiwi" ///
    223 "Dates" ///
    224 "Figs" ///
    225 "Passion Fruit" ///
    226 "Guava" ///
    227 "Papaya" ///
    228 "Mango" ///
    229 "Coffee" ///
    230 "Cacao" ///
    242 "Aquaculture" ///
    243 "Bananas" ///
    244 "Plantains" ///
    245 "Mangoes" ///
    246 "Pineapples" ///
    247 "Taro" ///
    248 "Eggplants" ///
    249 "Gourds" ///
    250 "Cranberries" ///
    254 "Dbl Crop Barley/Soybeans" ///
	998 "Total" ///
    , replace
}
label values CDL_CATE cdl_legend
egen total_100sqm = sum(solar_100sqm)
drop countyshare
replace solar_100sqm = total_100sqm if CDL_CATE==998
replace solar_ctyperc_catearea = 0.69 if CDL_CATE==998
replace solar_twpperc_catearea = 11.49851 if CDL_CATE==998
drop solar_ctyperc_totarea solar_twpperc_totarea total_100sqm
save "$dta\CDL_ImpbyCate_WASHTENAW_short.dta",replace
export delimited using "$dta\CDL_AgSharebyCate_WASHTENAWSolar_short.csv",replace

*Total Market Value change in farm products (gross revenue)
*County value by product is from USDA agstat for MI (NASS based)
use "$dta\CDL_ImpbyCate_WASHTENAW_short.dta",clear
gen County_ProductVal_kd=.
replace County_ProductVal_kd = 33286 if CDL_CATE==1
replace County_ProductVal_kd = 32224 if CDL_CATE==5
replace County_ProductVal_kd = 5582 if CDL_CATE==24
replace County_ProductVal_kd = 141322 if CDL_CATE==998
gen Loss_ProductVal_kd = (solar_ctyperc_catearea/100)*County_ProductVal_kd

*Assume other categories will lose X percent in value - X decided by weighted average of proportion
gen missing = (Loss_ProductVal_kd==.)
egen prop_ave_other = mean(solar_ctyperc_catearea*solar_100sqm/(97202-30555-26982-13882)), by(missing)

drop if Loss_ProductVal_kd==.
replace Loss_ProductVal_kd=. if CDL_CATE==998

local OtherProductVal=141322-5582-33286-32224
local missing_prop=0.0282749
egen Total_Loss = sum(Loss_ProductVal_kd)
replace Total_Loss=Total_Loss+`OtherProductVal'*`missing_prop'/100

replace Loss_ProductVal_kd = Total_Loss if Loss_ProductVal_kd==.
drop solar_twpperc_catearea Total_Loss missing prop_ave_other

*Convert to 2026 dollar
replace County_ProductVal_kd = County_ProductVal_kd*1.1075
replace Loss_ProductVal_kd = Loss_ProductVal_kd*1.1075
drop solar_100sqm solar_ctyperc_catearea County_ProductVal_kd
save "$dta\CDL_LossProdVal_byCate_WASHTENAWSolar.dta",replace
export delimited using "$dta\CDL_LossProdVal_byCate_WASHTENAWSolar.csv",replace
*Product value loss are based on 2022 ag census product value. The losses are calculated from the acreage loss in the solar site multiplied by expected production value per acre, assuming production homogeneity across county.

*Estimated Loss in other matrices - net cash income, gov payment, farm production expenses (covering farm labor) 
use "$dta\CDL_LossProdVal_byCate_WASHTENAWSolar.dta",clear
keep if CDL_CATE==998
gen County_netcashincome=16884
gen County_ProductVal_kd = 141322 
gen Loss_netcashinc=Loss_ProductVal_kd/County_ProductVal_kd * County_netcashincome

gen County_govpayment=2549
gen Loss_govpay=Loss_ProductVal_kd/County_ProductVal_kd * County_govpayment

gen County_farmexpenses=139138
gen Loss_farmexpenses=Loss_ProductVal_kd/County_ProductVal_kd * County_farmexpenses
keep CDL_CATE Loss_*

export delimited using "$dta\CDL_LossMatrix_WASHTENAWSolar.csv",replace

*Other matrices are calculated from proportional production (value) loss in the solar site, assuming homogeneity across county.
