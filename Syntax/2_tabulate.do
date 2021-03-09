*Set working directory
cd "T:\PAC\Research\COVID-19\"

*Required programs
which folders

*Indicators
global indicators healthseeking fsec remotelearning remotelearning_primary remotelearning_secondary schoolreturn cashtransfer cashtransfer_delay govtsupport medicine medicaltreatment natalcare schoolattendance teacher fseccovid

*Calculate group-specific rates for surveys/rounds/indicators (saved in folder /dat in working directory)
fs "prep/KHM*.dta"
foreach file in `r(files)' {
	use "prep/`file'", clear
	gen countrycode=upper(substr("`file'",1,3))
	cap confirm var round
	if _rc!=0 {
		gen round=substr("`file'",-5,1)
		destring round, replace
	}
	gen source="ipa" if substr("`file'",5,3)=="ipa"
	replace source="wb" if substr("`file'",5,2)=="wb"
	replace source="yl" if substr("`file'",5,2)=="yl"
	gen group=""
	gen groupvalue=.
	gen grouplabel=""
	cap gen weight=1	// generate weight for IPA surveys
	
	*National average
	replace group="all" in 1	
	foreach ind of global indicators {
		gen value`ind'=.
		gen ss`ind'=.
		gen se`ind'=.
		cap confirm var `ind'
		if _rc==0 { 
		qui sum `ind'
		if r(N)>25 { 
			qui reg `ind' [aw=weight]
			replace value`ind'=_b[_cons]*100 in 1
			replace se`ind'=_se[_cons]*100 in 1
			replace ss`ind'=e(N) in 1
		}
		}
	}
	
	*Gender
	replace group="sex" in 2/3
	replace groupvalue=1 in 2
	replace grouplabel="Male" in 2
	replace groupvalue=2 in 3
	replace grouplabel="Female" in 3
	foreach ind of global indicators {
		cap confirm var `ind'
		if _rc==0 { 
		qui sum `ind' if sex!=.
		if `r(N)'>25 {
			qui reg `ind' [aw=weight] if sex==1
			replace value`ind'=_b[_cons]*100 in 2
			replace se`ind'=_se[_cons]*100 in 2
			replace ss`ind'=e(N) in 2
			qui reg `ind' [aw=weight] if sex==2
			replace value`ind'=_b[_cons]*100 in 3
			replace se`ind'=_se[_cons]*100 in 3
			replace ss`ind'=e(N) in 3
		}
		}
	}
	*Location
	replace group="location" in 4/5
	replace groupvalue=1 in 4
	replace grouplabel="Urban" in 4
	replace groupvalue=2 in 5
	replace grouplabel="Rural" in 5
	foreach ind of global indicators {
		cap confirm var `ind'
		if _rc==0 { 
		qui sum `ind' if location!=.
		if `r(N)'>25 {
			qui reg `ind' [aw=weight] if location==1
			replace value`ind'=_b[_cons]*100 in 4
			replace se`ind'=_se[_cons]*100 in 4
			replace ss`ind'=e(N) in 4
			cap qui reg `ind' [aw=weight] if location==2
			cap replace value`ind'=_b[_cons]*100 in 5
			cap replace se`ind'=_se[_cons]*100 in 5
			cap replace ss`ind'=e(N) in 5
		}
		}
	}
	*Wealth
	cap confirm var poor
	if _rc==0 {
		replace group="wealth" in 6/10
		forvalue i=1/5 {
			local j=6+`i'-1
			replace groupvalue=`i' in `j'
		}
		replace grouplabel="Poorest 20%" if group=="wealth" & groupvalue==1
		replace grouplabel="Richest 20%" if group=="wealth" & groupvalue==5
		foreach ind of global indicators {
			cap confirm var `ind'
			if _rc==0 { 
			qui sum `ind' if wealth!=.
			if `r(N)'>25 {
				levelsof wealth, local(wealth)
				foreach i of local wealth {
					local j=6+`i'-1
					cap qui reg `ind' [aw=weight] if wealth==`i'
					cap replace value`ind'=_b[_cons]*100 in `j'
					cap replace se`ind'=_se[_cons]*100 in `j'
					cap replace ss`ind'=e(N) in `j'
				}
			}
			}
		}
	}
	*Poverty
	cap confirm var poor
	if _rc==0 {
		replace group="poor" in 11/12
		replace groupvalue=0 in 11
		replace grouplabel="Non poor" in 11
		replace groupvalue=1 in 12
		replace grouplabel="Poor" in 12
		foreach ind of global indicators {
			cap confirm var `ind'
			if _rc==0 { 
			qui sum `ind' if poor!=.
			if `r(N)'>25 {
				qui reg `ind' [aw=weight] if poor==0
				replace value`ind'=_b[_cons]*100 in 11
				replace se`ind'=_se[_cons]*100 in 11
				replace ss`ind'=e(N) in 11
				qui reg `ind' [aw=weight] if poor==1
				replace value`ind'=_b[_cons]*100 in 12
				replace se`ind'=_se[_cons]*100 in 12
				replace ss`ind'=e(N) in 12
			}
			}
		}
	}
	*Disability
	cap confirm var disability
	if _rc==0 {
		replace group="disability" in 13/14
		replace groupvalue=0 in 13
		replace grouplabel="No disability" in 13
		replace groupvalue=1 in 14
		replace grouplabel="With disability" in 14
		foreach ind of global indicators {
			cap confirm var `ind'
			if _rc==0 { 
			qui sum `ind' if disability!=.
			if `r(N)'>25 {
				qui reg `ind' [aw=weight] if disability==0
				replace value`ind'=_b[_cons]*100 in 13
				replace se`ind'=_se[_cons]*100 in 13
				replace ss`ind'=e(N) in 13
				qui reg `ind' [aw=weight] if disability==1
				replace value`ind'=_b[_cons]*100 in 14
				replace se`ind'=_se[_cons]*100 in 14
				replace ss`ind'=e(N) in 14
			}
			}
		}
	}
	*Regions
	gen regid2=""
	local j=15
	local lbe: value label region
	levelsof region, local(reg)
	foreach r of local reg {
		replace group="reg" in `j'
		replace groupvalue=`r' in `j'
		cap local lab: label `lbe' `r'
		cap local lab2=proper("`lab'")
		cap replace grouplabel="`lab2'" in `j'
		cap levelsof regid if region==`r', local(regid)
		if !missing(regid) {
			cap replace regid2=`regid' in `j'
		}
		foreach ind of global indicators {
		cap confirm var `ind'
		if _rc==0 {
			/*qui */sum `ind' [aw=weight] if region==`r'
			if `r(N)'>1 {
				/*qui */reg `ind' if region==`r'
				replace value`ind'=_b[_cons]*100 in `j'
				replace se`ind'=_se[_cons]*100 in `j'
				replace ss`ind'=e(N) in `j'
			}
		}
		}
		local j=`j'+1
	}
	drop if group==""
	keep countrycode group* value* source round ss* se* regid2
	drop sex
	ren regid2 regid
	local ccode=countrycode[1]
	local source=source[1]
	local round=round[1]	
	save "dat/_`ccode'_`source'_r`round'.dta", replace
}
	
*Merge different surveys/rounds
clear
fs "dat/_*.dta"
foreach file in `r(files)' {
	append using "dat/`file'"
}
order countrycode source round group* regid

replace ssremotelearning=ssremotelearning_primary if valueremotelearning==. & valueremotelearning_primary!=.	// if remote learning does not exist for all age groups, use primary school only
replace seremotelearning=seremotelearning_primary if valueremotelearning==. & valueremotelearning_primary!=.	
replace valueremotelearning=valueremotelearning_primary if valueremotelearning==. & valueremotelearning_primary!=.	
replace sshealthseeking=ssmedicaltreatment if valuehealthseeking==. & valuemedicaltreatment!=.					// in World Bank surveys, medical treatment describes access to health seeking behaviour (reverese describes lack of, as measured in IPA surveys)
replace sehealthseeking=semedicaltreatment if valuehealthseeking==. & valuemedicaltreatment!=.	
replace valuehealthseeking=100-valuemedicaltreatment if valuehealthseeking==. & valuemedicaltreatment!=.	

merge 1:1 countrycode source round group groupvalue using "dat/wb_dashboard.dta"
gen wb_dashboard=1 if _merge==2
list countrycode source round valueremotelearning indicator_valremotelearning if _merge==3 & group=="all"
list countrycode source round valuehealthseeking indicator_valhealthseeking if _merge==3 & group=="all"
list countrycode source round valuegovtsupport indicator_valgovtsupport if _merge==3 & group=="all"
foreach ind in healthseeking remotelearning govtsupport {
	replace ss`ind'=sample_subset`ind' if wb_dashboard==1 & value`ind'==. & indicator_val`ind'!=.
	replace value`ind'=indicator_val`ind' if wb_dashboard==1 & value`ind'==. & indicator_val`ind'!=.
}
drop _merge sample_s* indicator_val*
replace grouplabel="National average" if group=="all"
replace group="region" if group=="reg"
save "dat/tabulation.dta", replace
