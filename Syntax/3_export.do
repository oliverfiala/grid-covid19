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

*Reshape
duplicates list countrycode group groupvalue round source
reshape long value ss se, i(countrycode group groupvalue source round) j(indicator) string

*Keep most relevant observations in countries with multiple surveys
keep if indicator=="healthseeking" | indicator=="fsec" | indicator=="remotelearning" | indicator=="schoolreturn" | indicator=="govtsupport" | indicator=="cashtransfer_delay"
drop if countrycode=="IND" & indicator=="govtsupport" & group!="all"	// currently only Young Lives data in India; drop government support data
drop if countrycode=="ETH" & indicator=="fsec" & source=="yl"					// use WB data as it is more recent and uses FAO FIES scale questions
drop if countrycode=="ETH" & indicator=="remotelearning" & source=="wb"			// use YL data as it is more recent (Nov-Dec 2020 vs Aug-Sept 2020) and is also disaggregated by wealth
drop if countrycode=="ETH" & indicator=="govtsupport" & source=="yl"			// use WB data as it is more recent
drop if countrycode=="VNM" & indicator=="fsec" & source=="yl"					// use WB data as it uses FAO FIES scale questions
drop if countrycode=="VNM" & indicator=="remotelearning" & source=="wb"			// use YL data as it has data from November-December 2020 (R3), whereas the WB has data from July 2020 (R1).
drop if countrycode=="VNM" & indicator=="govtsupport" & source=="yl"			// use WB data as both sources date back to July 2020 (R1), but YL respondents are young adults and not children.
drop if countrycode=="VNM" & indicator=="schoolreturn" & source=="yl"			// use WB data as both sources date back to July 2020 (R1), but WB offers regional disaggregation

*Identify latest round for each country/indicator				// this requires months/years; currently based on rounds (works only within surveys)
egen _last=max(round) if value!=., by(countrycode indicator)
gen last=1 if round==_last
egen _first=min(round) if value!=., by(countrycode indicator)

*Merge with population estimates for 2020 (including country names and Iso2 codes) & keep only relevant indicators
merge m:1 countrycode using "dat/population2020.dta", nogen keep(1 3)
keep if group=="all" | group=="region" | group=="location" | group=="wealth" | group=="poor" | group=="disability"
drop if group=="wealth" & groupvalue!=1 & groupvalue!=5		// keep only poorest and richest quintiles
drop if group=="region" & regid==""							// drop regions where not regid exists as those cannot be displayed in map
drop if group=="region" & last!=1							// keep only latest value for regions (otherwise this creates an error in calculating worst/best region)
drop if value==.
drop if ss<25 & group!="region"								// drop observations with sample sizes <25
replace value=. if ss<25 & group=="region"
drop if countrycode=="MLI" & indicator=="schoolreturn"		// Schools had not been reopened widely at the time of survey
replace country="India (Andhra Pradesh & Telangana)" if countrycode=="IND" & source=="yl"
gen _count=1
egen _nrgroups=sum(_count), by(countrycode source round indicator group)
drop if group=="disability" & _nrgroups<2					// drop "no disability" if no data exist for group with disability

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

*Prepare trends (calculate rate of change, identify if inclusive progress exists)
replace groupvalue=0 if group=="all"
gen modate=ym(year, month)
format %tm modate
sort countrycode round group
egen _nrrounds=count(round) if value!=., by(countrycode group indicator groupvalue)
gen _ln=ln(value)
replace _ln=ln(0.01) if value==0
gen rr=.
levelsof countrycode, local(countrycode)
levelsof indicator, local(indicator)
levelsof group if group!="region", local(group)
foreach ccode of local countrycode {
foreach ind of local indicator {
foreach gr of local group {
	qui sum groupvalue if countrycode=="`ccode'" & indicator=="`ind'" & group=="`gr'" & _nrrounds>1 & _nrrounds!=.
	if r(N)>0 {
		levelsof groupvalue if countrycode=="`ccode'" & indicator=="`ind'" & group=="`gr'" & _nrrounds>1 & _nrrounds!=., local(groupvalue)
		foreach grv of local groupvalue {
			qui reg _ln modate if countrycode=="`ccode'" & indicator=="`ind'" & group=="`gr'" & groupvalue==`grv' & _nrrounds>1 & _nrrounds!=.
			replace rr=_b[modate] if rr==. & countrycode=="`ccode'" & indicator=="`ind'" & group=="`gr'" & groupvalue==`grv' & _nrrounds>1 & _nrrounds!=.
		}
	}
}
}
}
egen _minval=min(value) if _first==round, by(countrycode indicator group)
egen _minrr=min(rr) if _first==round, by(countrycode indicator group)
gen _ip=.
replace _ip=1 if rr<0 & (_minval==value & _minrr!=rr) & group!="all"							// inclusive progress when the better performing group (those where _minval==value) are not the fastest progressing ones (_minrr!=rr)
replace _ip=2 if ((rr>0 & rr!=.) | (rr<0 & (_minval==value & _minrr==rr))) & group!="all"		// inclusive progress when the better performing group (those where _minval==value) are not the fastest progressing ones (_minrr!=rr)
egen ip=mean(_ip), by(countrycode indicator group)
gen trends=1 if _nrrounds>1 & _nrrounds!=.

duplicates list countrycode group groupvalue indicator round
duplicates list countrycode group groupvalue indicator if last==1

*Other preparation for export to Tableau
ren source sr
replace sr="wb_dashboard" if sr=="wb" & wb_dashboard==1
drop _* pop* sp_urb_totl_in_zs wb_dashboard
replace rr=rr*100

*Export disaggreagted data & trends (visualisation 2 and 3)
preserve
	keep if disagreggation==1
	export delimited "dat/grid_covid19_disagg.csv", replace nolabel
	export delimited "C:\Users\OFiala\OneDrive - Save the Children UK\GRID local\Tableau\tableau_covid19.csv", replace nolabel
restore	
	
*Export national averages (visualisation 1)
preserve
	keep if last==1 & group=="all"
	drop group* regid rr ip
	ren country country_national
	export delimited "dat/grid_covid19_national.csv", replace nolabel
	export delimited "C:\Users\OFiala\OneDrive - Save the Children UK\GRID local\Tableau\tableau_covid19_national.csv", replace nolabel
restore

