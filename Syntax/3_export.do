*Set working directory
cd "T:\PAC\Research\COVID-19\"

*Open Tabulation & identify relevant observations and surveys
use "dat/tabulation.dta", clear
gen _disagg=0
replace _disagg=1 if group!="all"
egen disagreggation=max(_disagg), by(countrycode source round)	// Identify surveys with disaggregation
egen _dissagg_othersources=max(_disagg), by(countrycode)
drop if disagreggation==0 & _dissagg_othersources==1			// if multiple sources exist, drop surveys without disaggregated data
drop _*

bysort countrycode: tab source									// identify countries in which more than one survey has been performed; keep more relevant ones
drop if countrycode=="BFA" & source=="ipa"						// keep WB survey for BFA as it includes multiple rounds
drop if countrycode=="CAF" & wb_dashboard==1					// missing information on timing of survey in Central African Republic
drop if (countrycode=="VNM" | countrycode=="ETH") & source=="yl"

*Reshape
duplicates list countrycode group groupvalue round source
reshape long value ss se, i(countrycode group groupvalue source round) j(indicator) string

*Identify latest round for each country/indicator				// this requires months/years; currently based on rounds (works only within surveys)
egen _last=max(round) if value!=., by(countrycode indicator)
gen last=1 if round==_last
drop _*

*Merge with population estimates for 2020 (including country names and Iso2 codes) & keep only relevant indicators
merge m:1 countrycode using "dat/population2020.dta", nogen keep(1 3)
keep if group=="all" | group=="region" | group=="location" | group=="wealth" | group=="poor" | group=="disability"
drop if group=="wealth" & groupvalue!=1 & groupvalue!=5		// keep only poorest and richest quintiles
drop if group=="region" & regid==""							// drop regions where not regid exists as those cannot be displayed in map
drop if group=="region" & last!=1							// keep only latest value for regions (otherwise this creates an error in calculating worst/best region)
keep if indicator=="healthseeking" | indicator=="fsec" | indicator=="remotelearning" | indicator=="schoolreturn" | indicator=="govtsupport" | indicator=="cashtransfer_delay"
drop if value==.
drop if ss<25 & group!="region"								// drop observations with sample sizes <25
replace value=. if ss<25 & group=="region"
drop if countrycode=="MLI" & indicator=="schoolreturn"		// Schools had not been reopened widely at the time of survey
replace disagreggation=0 if countrycode=="IND" & indicator=="govtsupport"	// no variation in government support in India
drop if countrycode=="IND" & indicator=="govtsupport" & group!="all"
replace country="India (Andhra Pradesh & Telangana)" if countrycode=="IND" & source=="yl"
gen _count=1
egen _nrgroups=sum(_count), by(countrycode source round indicator group)
drop if group=="disability" & _nrgroups<2					// drop "no disability" if no data exist for group with disability
drop _*

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
replace sr="wb_dashboard" if sr=="wb" & wb_dashboard==1
drop pop* sp_urb_totl_in_zs _* wb_dashboard

*Export disaggreagted data (visualisation 2)
preserve
	keep if last==1 & disagreggation==1
	export delimited "dat/grid_covid19_disagg.csv", replace nolabel
	export delimited "C:\Users\OFiala\OneDrive - Save the Children UK\GRID local\Tableau\tableau_covid19.csv", replace nolabel
restore

*Export trend data (visualisation 3)
/*
preserve
	keep if trends=1 /* disagreggation==1*/
	export delimited "dat/grid_covid19_trends.csv", replace nolabel
	export delimited "C:\Users\OFiala\OneDrive - Save the Children UK\GRID local\Tableau\tableau_covid19_trends.csv", replace nolabel
restore
*/

*Export national averages (visualisation 1)
preserve
	keep if last==1 & group=="all"
	drop group* regid
	ren country country_national
	export delimited "dat/grid_covid19_national.csv", replace nolabel
	export delimited "C:\Users\OFiala\OneDrive - Save the Children UK\GRID local\Tableau\tableau_covid19_national.csv", replace nolabel
restore
