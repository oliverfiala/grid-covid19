*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*--- ROUND 1 ---
*Open first survey
use "source\yl\IND\in_yc_covid_arch.dta", clear
gen cohort=1
tempfile in_yc_covid_arch
save `in_yc_covid_arch', replace

use "source\yl\IND\in_oc_covid_arch.dta", clear
gen cohort=2
append using `in_yc_covid_arch'
tempfile in_covid_arch
save `in_covid_arch', replace

*Open second survey
use "source\yl\IND\in_oc_covid_householdrostercov1_arch.dta", clear
gen cohort=2
tempfile in_oc_covid_hh_arch
save `in_oc_covid_hh_arch', replace

use "source\yl\IND\in_yc_covid_householdrostercov1_arch.dta", clear
gen cohort=1
append using `in_oc_covid_hh_arch'

*Merge
merge m:1 CHILDCODE using `in_covid_arch', nogen

*Disaggregation
rename typesite_fc location
replace location=2 if location==0 	// 1 Urban 2 Rural
gen poor=1
replace poor=0 if hep_group==1
rename ACCINTCOV1 internetaccess
rename STABLGCOV1 region		//1 TS 2 AP
rename MEMAGECOV1 age
replace age=. if age==-99
rename MEMSEXCOV1 sex
replace sex=. if sex==88

*Variables of interest
gen govtsupport=.		//With these criteria everyone received support
replace govtsupport=0 if RCVSP1COV1=="N" & RCVSP2COV1=="N" & RCVSP3COV1=="N" & RCVSP4COV1=="N" & RCVSP5COV1=="N" & RCVSP6COV1=="N" & RCVSP7COV1=="N" & RCVSP8COV1=="N" & RCVSP9COV1=="N" & RCVSP10COV1=="N" & RCVSP11COV1=="N" & RCVSP12COV1=="N" & RCVSP13COV1=="N" & RCVSP14COV1=="N" & RCVSP15COV1=="N" & RCVSP16COV1=="N" & RCVSP17COV1=="N" & RCVSP18COV1=="N"
replace govtsupport=1 if RCVSP1COV1=="Y" | RCVSP2COV1=="Y" | RCVSP3COV1=="Y" | RCVSP4COV1=="Y" | RCVSP5COV1=="Y" | RCVSP6COV1=="Y" | RCVSP7COV1=="Y" | RCVSP8COV1=="Y" | RCVSP9COV1=="Y" | RCVSP10COV1=="Y" | RCVSP11COV1=="Y" | RCVSP12COV1=="Y" | RCVSP13COV1=="Y" | RCVSP14COV1=="Y" | RCVSP15COV1=="Y" | RCVSP16COV1=="Y" | RCVSP17COV1=="Y" | RCVSP18COV1=="Y"

rename WNTHNGCOV1 fsec 		//Time household ran out of food at least once since outbreak

*Variables of interest
rename HHUN191COV1 schoolinterrupt
replace schoolinterrupt=. if schoolinterrupt==88

rename HHUN192COV1 schooldropout
gen schoolreturn=.
replace schoolreturn=1 if schooldropout==0
replace schoolreturn=0 if schooldropout==1
replace schoolreturn=. if schooldropout==88

rename HHUN193COV1 schoolremote
replace schoolremote=. if schoolremote==88

gen remotelearning=.
replace remotelearning=1 if schoolinterrupt==1 & schoolremote==1
replace remotelearning=0 if schoolinterrupt==1 & schoolremote==0

gen schoolswitch=.

/*
gen outofschool=.
replace outofschool=0 if schoolinterrupt==0 | schoolreturn==0 | schoolremote==1
replace outofschool=1 if schoolinterrupt==1 & schoolremote==0

*Other variables
gen homeworking=0		//Started working remotely due to COVID-19
replace homeworking=. if WRKHMECOV1==0 | WRKHMECOV1==88		
replace homeworking=1 if WRKHMECOV1==4

gen wellbeing=.
replace wellbeing=1 if SUBWELCOV1<=3	//1 Okay 0 Not okay
replace wellbeing=0 if SUBWELCOV1>=4
*/

*Save
keep cohort age sex location poor region internetaccess fsec schoolinterrupt schoolreturn schoolremote /*homeworking wellbeing outofschool*/ remotelearning schoolswitch
save "prep/IND_yl_r1.dta", replace
