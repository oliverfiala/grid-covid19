*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUNDS 1-2 ---

*Open survey
forvalues r=1/2 {
use "source\wb\DJI\ecv_household_wave`r'.dta", clear

if `r'==2 {
merge 1:m hid_2 using "source\wb\DJI\ecv_education_wave`r'.dta", nogen
}

gen round=`r'
gen year=2020
gen month=.

*Weights
if `r'==1 {
	rename wgt_hh2 weight
	replace month=7
}
if `r'==2 {
	rename wt_hh_2 weight
	replace month=10
}

*Prepare dataset by renaming & creating variables of interest
gen location=1		//Urban
gen region=.		//Not specificied
gen sex=.
gen wealth=.
*poverty variable already called "poor"

*Health
gen medicaltreatment=.
gen medicine=.
gen vaccination=.
gen maternalcare=.
if `r'==1 {
	replace medicaltreatment=1 if s07q3==1		//No timeframe
	replace medicaltreatment=0 if s07q3==2
}
if `r'==2 {
	replace medicine=1 if s06q1a_6==1
	replace medicine=0 if s06q1a_6==2
	replace vaccination=1 if s07q2a_2==1
	replace vaccination=0 if s07q2a_1==2
	replace maternalcare=1 if s07q2a_1==1
	replace maternalcare=0 if s07q2a_1==2
}

*Nutrition (FIES scale http://www.fao.org/3/a-as583e.pdf)
gen fies=.
gen fsec=.
if `r'==1 {
	replace fsec=1 if s06q3==1		//Past 30 days (severe)
	replace fsec=0 if s06q3==2
}
if `r'==2 {
	replace fies=0 if s09q1==2 & s09q2==2 & s09q3==2 & s09q4==2 & s09q5==2 & s09q6==2 & s09q7==2 & s09q8==2		//Past 30 days
	replace fies=1 if s09q1==1 | s09q2==1 | s09q3==1
	replace fies=2 if s09q4==1 | s09q5==1 | s09q6==1
	replace fies=3 if s09q7==1 | s09q8==1
	replace fsec=0 if fies==0 | fies==1
	replace fsec=1 if fies==2 | fies==3
}

*Education
gen schoolstop=.
gen schoolreturn=.
gen remotelearning_primary=.
gen remotelearning_secondary=.
if `r'==1 {
	replace schoolstop=1 if s03q3_6==1		//Children not going to school as preventive measure against COVID-19
	replace schoolstop=0 if s03q3_6==2

	replace remotelearning_primary=1 if s07q6_1==1 | s07q6_2==1 | s07q6_3==1 | s07q6_4==1 | s07q6_5==1 | s07q6_6==1 | s07q6_7==1 | s07q6_8==1 | s07q6_9==1 | s07q6_10==1
	replace remotelearning_primary=0 if s07q6_1==0 & s07q6_2==0 & s07q6_3==0 & s07q6_4==0 & s07q6_5==0 & s07q6_6==0 & s07q6_7==0 & s07q6_8==0 & s07q6_9==0 & s07q6_10==0

	replace remotelearning_secondary=1 if s07q8_1==1 | s07q8_2==1 | s07q8_3==1 | s07q8_4==1 | s07q8_5==1 | s07q8_6==1 | s07q8_7==1 | s07q8_8==1
	replace remotelearning_secondary=0 if s07q8_1==0 & s07q8_2==0 & s07q8_3==0 & s07q8_4==0 & s07q8_5==0 & s07q8_6==0 & s07q8_7==0 & s07q8_8==0
	gen remotelearning=remotelearning_primary		//Will display in COVID-19 dashboard
}

if `r'==2 {
	replace schoolreturn=1 if s07q5a==1
	replace schoolreturn=0 if s07q5a==2 & s07q6a_06!=1
	
	gen remotelearning=.
}

*Social protection
gen govtsupport=.
if `r'==1 {
	replace govtsupport=1 if s08q1_2==1 | s08q1_3==1	//Assistance in the form of food or food stamps from government or other institution over past 30 days
	replace govtsupport=0 if s08q1_2==2 & s08q1_3==2
}

gen incomeloss=.			//Income from family enterprise over past 30 days if relevant
replace incomeloss=0 if s04q11==1 | s04q11==2
replace incomeloss=1 if s04q11==3 | s04q11==4
replace incomeloss=. if s04q11==8

gen jobloss=.
replace jobloss=1 if s04q6==3 | s04q6==4		//Main breadwinner decreased or stopped working over past week
replace jobloss=0 if s04q6==1 | s04q6==2
replace jobloss=. if s04q6==8

gen govtsupport_change=.
replace govtsupport_change=1 if s05q2_8==3		//Over the past 30 days usual govt support decreased
replace govtsupport_change=0 if s05q2_8==1 | s05q2_8==2

*Regional attribution
gen regid=.

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth poor medicaltreatment medicine maternalcare vaccination schoolstop schoolreturn remotelearning* fsec govtsupport incomeloss jobloss govtsupport_change weight round month year
save "prep\DJI_wb_r`r'.dta", replace
}
