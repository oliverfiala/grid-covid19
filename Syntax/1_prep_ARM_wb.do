*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUND 1 ---
*Open survey
use "source\wb\ARM\arm_covid_vuln_2020_surv2_vfinal.dta", clear

*Disaggregation
rename q6 region
rename q7 location
replace location=1 if location==3		//Location 1 urban 2 rural
rename bq2 sex		//Sex of the child 1 male 2 female
gen disability=.
replace disability=1 if bq3==2 | bq3==3 | bq3==4
replace disability=0 if bq3==1

gen round=1
*weight already called weight for individual children

*Health
gen medicaltreatment=.
replace medicaltreatment=1 if bq12==1		//Child received necessary health service during state of emergency
replace medicaltreatment=0 if bq12==2

gen immunization=.
replace immunization=1 if bq16==1		//Child was taken to vaccination during state of emergency when vaccination was due
replace immunization=0 if bq16==2

*Education
gen remotelearning=.
replace remotelearning=1 if  bq34==1
replace remotelearning=0 if  bq34==2		//Child was involved in distance/home-based learning

gen teacher=.
replace teacher=1 if bq38==1 | bq38==2		//Most to all teacher supported
replace teacher=0 if bq38==3 | bq38==4

gen schoolreturn=.
replace schoolreturn=1 if bq48==1 | bq48==2
replace schoolreturn=0 if bq48==3 | bq48==4

*Regional attribution
gen regid=""
replace regid="ARM.4_1" if region==1
replace regid="ARM.2_1" if region==2
replace regid="ARM.3_1" if region==3
replace regid="ARM.1_1" if region==4
replace regid="ARM.5_1" if region==5
replace regid="ARM.6_1" if region==6
replace regid="ARM.7_1" if region==7
replace regid="ARM.8_1" if region==8
replace regid="ARM.9_1" if region==9
replace regid="ARM.10_1" if region==10
replace regid="ARM.11_1" if region==11

*Save
keep sex location region disability regid medicaltreatment immunization remotelearning schoolreturn teacher weight
save "prep\ARM_wb_r1.dta", replace
