*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*--- ROUND 1 ---

local ccode ETH IND PER VNM
foreach c of local ccode {
	*Open first survey
	use "source\yl/`c'/`c'_yc_covid_arch.dta", clear
	gen cohort=1
	tempfile `c'_yc_covid_arch
	save ``c'_yc_covid_arch', replace

	use "source\yl/`c'/`c'_oc_covid_arch.dta", clear
	gen cohort=2
	append using ``c'_yc_covid_arch'
	tempfile `c'_covid_arch
	save ``c'_covid_arch', replace

	*Open second survey
	use "source\yl/`c'/`c'_oc_covid_householdrostercov1_arch.dta", clear
	gen cohort=2
	tempfile `c'_oc_covid_hh_arch
	save ``c'_oc_covid_hh_arch', replace

	use "source\yl/`c'/`c'_yc_covid_householdrostercov1_arch.dta", clear
	gen cohort=1
	append using ``c'_oc_covid_hh_arch'

	*Merge
	merge m:1 CHILDCODE using ``c'_covid_arch', nogen

	gen ccode="`c'"

	*Disaggregation
	rename typesite_fc location
	replace location=2 if location==0 	// 1 Urban 2 Rural
	gen poor=1
	replace poor=0 if hep_group==1
	gen wealth=.
	rename ACCINTCOV1 internetaccess
	if "`c'"=="IND" {
		rename STABLGCOV1 region		//1 TS 2 AP
	}
	else {
		gen region=.
	}
	
	rename MEMAGECOV1 age
	replace age=. if age==-99 | age==-9 | age==-77 | age==-79

	rename MEMSEXCOV1 sex
	replace sex=. if sex==88 | sex==99

	*Variables of interest
	rename WNTHNGCOV1 fsec 		//Time household ran out of food at least once since outbreak
	if "`c'"=="ETH" {
		encode TYPSP1COV1, gen(govtsupport)
		replace govtsupport=0 if govtsupport==2
		replace govtsupport=0 if RCVSP1COV1=="N" & RCVSP2COV1=="N"
	}
	if "`c'"=="IND" {
		gen govtsupport=.		//With these criteria everyone received support
		replace govtsupport=0 if RCVSP1COV1=="N" & RCVSP2COV1=="N" & RCVSP3COV1=="N" & RCVSP4COV1=="N" & RCVSP5COV1=="N" & RCVSP6COV1=="N" & RCVSP7COV1=="N" & RCVSP8COV1=="N" & RCVSP9COV1=="N" & RCVSP10COV1=="N" & RCVSP11COV1=="N" & RCVSP12COV1=="N" & RCVSP13COV1=="N" & RCVSP14COV1=="N" & RCVSP15COV1=="N" & RCVSP16COV1=="N" & RCVSP17COV1=="N" & RCVSP18COV1=="N"
		replace govtsupport=1 if RCVSP1COV1=="Y" | RCVSP2COV1=="Y" | RCVSP3COV1=="Y" | RCVSP4COV1=="Y" | RCVSP5COV1=="Y" | RCVSP6COV1=="Y" | RCVSP7COV1=="Y" | RCVSP8COV1=="Y" | RCVSP9COV1=="Y" | RCVSP10COV1=="Y" | RCVSP11COV1=="Y" | RCVSP12COV1=="Y" | RCVSP13COV1=="Y" | RCVSP14COV1=="Y" | RCVSP15COV1=="Y" | RCVSP16COV1=="Y" | RCVSP17COV1=="Y" | RCVSP18COV1=="Y"
	}
	if "`c'"=="VNM" | "`c'"=="PER" {
		gen govtsupport=.		//No timeframe
		replace govtsupport=0 if RCVSPTCOV1==0
		replace govtsupport=1 if RCVSPTCOV1==1 | RCVSPTCOV1==2
	}
	rename HHUN191COV1 schoolinterrupt
	replace schoolinterrupt=. if schoolinterrupt==88

	rename HHUN192COV1 schooldropout
	gen schoolreturn=.
	replace schoolreturn=1 if schooldropout==0
	replace schoolreturn=0 if schooldropout==1
	replace schoolreturn=. if schooldropout==88

	rename HHUN193COV1 schoolremote
	replace schoolremote=. if schoolremote==88

	gen schoolswitch=.
	if "`c'"=="PER" | "`c'"=="VNM" {
		replace schoolswitch=1 if HHUN194COV1==1 | HHUN195COV1==1
		replace schoolswitch=0 if HHUN194COV1==0 & HHUN195COV1==0
	}

	gen remotelearning=.
	replace remotelearning=1 if schoolinterrupt==1 & schoolremote==1
	replace remotelearning=0 if schoolinterrupt==1 & schoolremote==0
	
	/*
	gen outofschool=.
	replace outofschool=0 if schoolinterrupt==0 | schooldropout==0 | schoolremote==1 /*| schoolswitch==1*/
	replace outofschool=1 if schoolinterrupt==1 & schoolremote==0
	
	*Other variables
	gen homeworking=0		//Started working remotely due to COVID-19
	replace homeworking=. if WRKHMECOV1==0		
	replace homeworking=1 if WRKHMECOV1==4

	gen wellbeing=.
	replace wellbeing=1 if SUBWELCOV1<=3	//1 Okay 0 Not okay
	replace wellbeing=0 if SUBWELCOV1>=4
	*/

	*Save
	keep ccode cohort location poor sex wealth region internetaccess age schoolinterrupt schoolreturn schoolremote remotelearning schoolswitch fsec /*outofschool homeworking wellbeing*/ govtsupport
	save "prep/`c'_yl_r1.dta", replace
}
