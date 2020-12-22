*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*--- ROUND 1 ---

*Open survey
use "source\wb\DJI\ecv_household_wave1.dta", clear

*Weights
rename wgt_hh2 weight

*Prepare dataset by renaming & creating variables of interest
gen location=1		//Urban
gen region=.		//Not specificied
gen sex=.
gen wealth=.
*poverty variable already called "poor"

*Health
gen medicaltreatment=.
replace medicaltreatment=1 if s07q3==1		//No timeframe
replace medicaltreatment=0 if s07q3==2

*Nutrition (FIES scale http://www.fao.org/3/a-as583e.pdf)
gen fsec=.
replace fsec=1 if s06q3==1		//Past 30 days (severe)
replace fsec=0 if s06q3==2

*Education
gen schoolstop=.
replace schoolstop=1 if s03q3_6==1		//Children not going to school as preventive measure against COVID-19
replace schoolstop=0 if s03q3_6==2

gen remotelearning_primary=.
replace remotelearning_primary=1 if s07q6_1==1 | s07q6_2==1 | s07q6_3==1 | s07q6_4==1 | s07q6_5==1 | s07q6_6==1 | s07q6_7==1 | s07q6_8==1 | s07q6_9==1 | s07q6_10==1
replace remotelearning_primary=0 if s07q6_1==0 & s07q6_2==0 & s07q6_3==0 & s07q6_4==0 & s07q6_5==0 & s07q6_6==0 & s07q6_7==0 & s07q6_8==0 & s07q6_9==0 & s07q6_10==0

gen remotelearning_secondary=.
replace remotelearning_secondary=1 if s07q8_1==1 | s07q8_2==1 | s07q8_3==1 | s07q8_4==1 | s07q8_5==1 | s07q8_6==1 | s07q8_7==1 | s07q8_8==1
replace remotelearning_secondary=0 if s07q8_1==0 & s07q8_2==0 & s07q8_3==0 & s07q8_4==0 & s07q8_5==0 & s07q8_6==0 & s07q8_7==0 & s07q8_8==0

gen remotelearning=remotelearning_primary		//Will display in COVID-19 dashboard

*Social protection
gen govtsupport=.
replace govtsupport=1 if s08q1_2==1 | s08q1_3==1	//Assistance in the form of food or food stamps from government or other institution over past 30 days
replace govtsupport=0 if s08q1_2==2 & s08q1_3==2

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

*Save
keep sex location region regid wealth poor medicaltreatment schoolstop remotelearning remotelearning_primary remotelearning_secondary schoolstop fsec govtsupport incomeloss jobloss govtsupport_change weight
save "prep\DJI_wb_r1.dta", replace
