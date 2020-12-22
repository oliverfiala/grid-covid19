*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*--- ROUND 1 ---
*Open first survey
use "source\yl\ETH\et_yc_covid_arch.dta", clear
gen cohort=1
tempfile et_yc_covid_arch
save `et_yc_covid_arch', replace

use "source\yl\ETH\et_oc_covid_arch.dta", clear
gen cohort=2
append using `et_yc_covid_arch'
tempfile et_covid_arch
save `et_covid_arch', replace

*Open second survey
use "source\yl\ETH\et_oc_covid_householdrostercov1_arch.dta", clear
gen cohort=2
tempfile et_oc_covid_hh_arch
save `et_oc_covid_hh_arch', replace

use "source\yl\ETH\et_yc_covid_householdrostercov1_arch.dta", clear
gen cohort=1
append using `et_oc_covid_hh_arch'

*Merge
merge m:1 CHILDCODE using `et_covid_arch', nogen

*Disaggregation
rename typesite_fc location
replace location=2 if location==0 	// 1 Urban 2 Rural
gen poor=1
replace poor=0 if hep_group==1
rename ACCINTCOV1 internetaccess
gen region=.
rename MEMAGECOV1 age
replace age=. if age==-99

rename MEMSEXCOV1 sex
replace sex=. if sex==88

*Variables of interest
encode TYPSP1COV1, gen(govtsupport)
replace govtsupport=0 if govtsupport==2
replace govtsupport=0 if RCVSP1COV1=="N" & RCVSP2COV1=="N"
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
replace homeworking=. if WRKHMECOV1==0		
replace homeworking=1 if WRKHMECOV1==4

gen wellbeing=.
replace wellbeing=1 if SUBWELCOV1<=3	//1 Okay 0 Not okay
replace wellbeing=0 if SUBWELCOV1>=4
*/

*Save
keep cohort age sex location poor region internetaccess fsec schoolinterrupt schoolreturn schoolremote /*homeworking wellbeing outofschool*/ remotelearning schoolswitch
save "prep/ETH_yl_r1.dta", replace



