*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUND 1 ---
*Open first survey
use "source\yl\PER\pe_yc_covid_arch.dta", clear
gen cohort=1
tempfile pe_yc_covid_arch
save `pe_yc_covid_arch', replace

use "source\yl\PER\pe_oc_covid_arch.dta", clear
gen cohort=2
append using `pe_yc_covid_arch'
tempfile pe_covid_arch
save `pe_covid_arch', replace

*Open second survey
use "source\yl\PER\pe_oc_covid_householdrostercov1_arch.dta", clear
gen cohort=2
tempfile pe_oc_covid_hh_arch
save `pe_oc_covid_hh_arch', replace

use "source\yl\PER\pe_yc_covid_householdrostercov1_arch.dta", clear
gen cohort=1
append using `pe_oc_covid_hh_arch'

*Merge
merge m:1 CHILDCODE using `pe_covid_arch', nogen

gen round=1
gen month=7
gen year=2020

*Disaggregation
rename typesite_fc location
replace location=2 if location==0 	// 1 Urban 2 Rural
gen poor=1
replace poor=0 if hep_group==1
rename ACCINTCOV1 internetaccess
gen region=.
rename MEMAGECOV1 age
replace age=. if age==-79 | age==-77
rename MEMSEXCOV1 sex
replace sex=. if sex==88 | sex==99

*Variables of interest
gen govtsupport=.
replace govtsupport=1 if  RCVSPTCOV1==1 |  RCVSPTCOV1==2
replace govtsupport=0 if  RCVSPTCOV1==0

rename WNTHNGCOV1 fsec 		//Time household ran out of food at least once since outbreak

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
replace schoolswitch=1 if HHUN194COV1==1 | HHUN195COV1==1
replace schoolswitch=0 if HHUN194COV1==0 & HHUN195COV1==0

gen remotelearning=.
replace remotelearning=1 if schoolinterrupt==1 & schoolremote==1
replace remotelearning=0 if schoolinterrupt==1 & schoolremote==0

/*
gen outofschool=.
replace outofschool=0 if schoolinterrupt==0 | schoolreturn==0 | schoolremote==1 /*| schoolswitch==1*/
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
keep cohort age sex location poor region internetaccess fsec schoolinterrupt schoolreturn schoolremote /*outofschool homeworking wellbeing*/ remotelearning schoolswitch round month year
save "prep/PER_yl_r1.dta", replace
