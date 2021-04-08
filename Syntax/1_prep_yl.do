*Set working directory
cd "T:\PAC\Research\COVID-19\"

*--- ROUNDS 1-3 ---

local ccode ETH IND PER VNM
foreach c of local ccode {
	forvalues r=1/3 {
	if `r'==1 {
		*Open first survey
		use "source\yl/`c'/Round `r'/`c'_yc_covid_arch.dta", clear
		gen cohort=1
		tempfile `c'_yc_covid_arch
		save ``c'_yc_covid_arch', replace

		use "source\yl/`c'/Round `r'/`c'_oc_covid_arch.dta", clear
		gen cohort=2
		append using ``c'_yc_covid_arch'
		tempfile `c'_covid_arch
		save ``c'_covid_arch', replace
	
		*Open second survey
		use "source\yl/`c'/Round `r'/`c'_oc_covid_householdrostercov1_arch.dta", clear
		gen cohort=2
		tempfile `c'_oc_covid_hh_arch
		save ``c'_oc_covid_hh_arch', replace

		use "source\yl/`c'/Round `r'/`c'_yc_covid_householdrostercov1_arch.dta", clear
		gen cohort=1
		append using ``c'_oc_covid_hh_arch'

		*Merge
		merge m:1 CHILDCODE using ``c'_covid_arch', nogen
		
		*Disaggregation
		/*rename MEMAGECOV1 age
		replace age=. if age==-99 | age==-9 | age==-77 | age==-79

		rename MEMSEXCOV1 sex
		replace sex=. if sex==88 | sex==99
		
		rename ACCINTCOV1 internetaccess*/
		
		
	}
	else {
		*Open younger cohort
		use "source\yl/`c'/Round `r'/`c'_yc_covid`r'_arch.dta", clear
		gen cohort=1
		tempfile `c'_yc_covid`r'_arch
		save ``c'_yc_covid`r'_arch', replace

		*Append to older cohort
		use "source\yl/`c'/Round `r'/`c'_oc_covid`r'_arch.dta", clear
		gen cohort=2
		append using ``c'_yc_covid`r'_arch', force
		tempfile `c'_covid`r'_arch
		save ``c'_covid`r'_arch', replace
	}
	gen ccode="`c'"

	*Disaggregation
	if `r'==1 {
		rename typesite_fc location
	}
	if `r'==2 {
		rename typesite_sc location
	}
	if `r'==3 {
		rename typesite_tc location
	}
	replace location=2 if location==0 	// 1 Urban 2 Rural
	gen poor=1
	replace poor=0 if hep_group==1
	gen wealth=.
	
	if `r'==1 & "`c'"=="IND" {
		rename STABLGCOV1 region		//1 TS 2 AP
	}
	else {
		gen region=.
	}
	
	gen round=`r'
	gen year=2020
	if `r'==1 {
		gen month=7
}
	if `r'==2 {
		gen month=10
}
	if `r'==3 & "`c'"!="IND" {
		gen month=12
}	
	if `r'==3 & "`c'"=="IND" {
		gen month=11
}	

	cap gen sex=.
	
	*Variables of interest
	*Food insecurity (R1)
	gen fsec=.
	if `r'==1 {
		replace fsec=WNTHNGCOV1		//Time household ran out of food at least once since outbreak
	}
	
	*Government support (R1)
	if `r'==1 {
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
	}
	else {
		gen govtsupport=.
	}
	
	*Education (R1-3)
	if `r'==1 {
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
	}
	if `r'!=1 & "`c'"!="PER" {
		gen remotelearning=.		//Young adult is enrolled in school and engaged in some form of learning, whether in person or remotely
		replace remotelearning=1 if ENED01COV`r'=="Y" | ENED02COV`r'=="Y" | ENED03COV`r'=="Y" | ENED04COV`r'=="Y" | ENED05COV`r'=="Y" | ENED06COV`r'=="Y" | ENED07COV`r'=="Y"
		replace remotelearning=0 if ENED01COV`r'=="N" & ENED02COV`r'=="N" & ENED03COV`r'=="N" & ENED04COV`r'=="N" & ENED05COV`r'=="N" & ENED06COV`r'=="N" & ENED07COV`r'=="N"
		
		gen schoolinterrupt=.
		gen schoolreturn=.
		gen schoolremote=.
	}
	if `r'!=1 & "`c'"=="PER" {
		gen remotelearning=.
		gen schoolinterrupt=.
		gen schoolreturn=.
		gen schoolremote=.
	}
	
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

	*Label
	label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label values month month

	*Save
	keep ccode cohort location poor wealth region sex /*internetaccess age*/ schoolinterrupt schoolreturn schoolremote remotelearning fsec /*schoolswitch outofschool homeworking wellbeing*/ govtsupport round month year
	save "prep/`c'_yl_r`r'.dta", replace
	}
}
