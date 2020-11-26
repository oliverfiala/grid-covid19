*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*Open Tabulation and reshape
use "dat/tabulation.dta", clear
replace ssremotelearning=ssremotelearning_primary if valueremotelearning==. & valueremotelearning_primary!=.	// if remote learning does not exist for all age groups, use primary school only
replace seremotelearning=seremotelearning_primary if valueremotelearning==. & valueremotelearning_primary!=.	
replace valueremotelearning=valueremotelearning_primary if valueremotelearning==. & valueremotelearning_primary!=.	
replace sshealthseeking=ssmedicaltreatment if valuehealthseeking==. & valuemedicaltreatment!=.		// in World Bank surveys, medical treatment describes access to health seeking behaviour (reverese describes lack of, as measured in IPA surveys)
replace sehealthseeking=semedicaltreatment if valuehealthseeking==. & valuemedicaltreatment!=.	
replace valuehealthseeking=100-valuemedicaltreatment if valuehealthseeking==. & valuemedicaltreatment!=.	

duplicates list countrycode group groupvalue round source
reshape long value ss se, i(countrycode group groupvalue source round) j(indicator) string

*Merge with population estimates for 2020 (including country names and Iso2 codes) & keep only relevant indicators
merge m:1 countrycode using "dat/population2020.dta", nogen keep(1 3)
keep if group=="all" | group=="region" | group=="location" | group=="wealth" | group=="poor"
drop if group=="wealth" & groupvalue!=1 & groupvalue!=5		// keep only poorest and richest quintiles
drop if group=="region" & regid==""							// drop regions where not regid exists as those cannot be displayed in map
keep if indicator=="healthseeking" | indicator=="fsec" | indicator=="remotelearning" | indicator=="schoolreturn" | indicator=="govtsupport" | indicator=="cashtransfer_delay"
drop if value==.
drop if ss<25 & group!="region"								// drop observations with sample sizes <25
replace value=. if ss<25 & group=="region"
drop if countrycode=="BFA" & source=="wb"					// keep RECOVR survey for BFA as it includes more relevant indicators
drop if countrycode=="MLI" & indicator=="schoolreturn"		// Schools had not been reopened widely at the time of survey

*Adjust regional labels
merge m:m regid using "dat/region_labels", keep(1 3) nogen
replace grouplabel=regname if group=="region" & regname!=""
drop regname

*Reverse indicator measure for education/social protection indicator to align with health/nutrition measures ("lack of")
replace value=100-value if indicator=="remotelearning" | indicator=="schoolreturn"
replace value=100-value if indicator=="govtsupport" | indicator=="cashtransfer" 

*Theme
gen theme="hn" if indicator=="healthseeking" | indicator=="fsec"
replace theme="ed" if indicator=="remotelearning" | indicator=="schoolreturn"
replace theme="sp" if indicator=="govtsupport" | indicator=="cashtransfer_delay"

*Absolute numbers of children affected
gen _ss=ss if group=="all"
egen _ssall=min(_ss), by(countrycode indicator)
gen _ssrelative=ss/_ssall
gen abs=value/100*pop0017*_ssrelative if theme!="ed"
replace abs=value/100*(pop0017-pop0004)*_ssrelative if theme=="ed"	// Assumption: education-relevant indicators apply to all children above age 5

*Other preparation for export to Tableau
ren source sr
drop year pop* sp_urb_totl_in_zs _*
drop round

export delimited "dat/grid_covid19.csv", replace nolabel
*export delimited "C:\Users\OFiala\OneDrive - Save the Children UK\GRID local\Tableau\tableau_covid19.csv", replace nolabel
