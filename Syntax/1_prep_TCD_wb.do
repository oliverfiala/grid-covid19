*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUND 1 ---

*Prepare income loss file
use "source\wb\TCD\round01_income.dta", clear
duplicates drop interview__key interview__id, force
gen incomeloss=0 if s07q02<=2		//Since beginning of the pandemic (March 2020)
replace incomeloss=1 if s07q02==3
tempfile round01_income
save `round01_income', replace

*Open surveys and merge with income loss
use "source\wb\TCD\round01_assistance.dta", clear
duplicates list hhid interview__key interview__id
duplicates drop hhid interview__key interview__id, force
merge 1:1 hhid using "source\wb\TCD\round01_household.dta", nogen
merge 1:1 interview__key interview__id using `round01_income', nogen keepusing(incomeloss)

gen month=6
gen year=2020

*Weights
rename Weight1 weight

*Prepare dataset by renaming & creating variables on interest
rename s00q01 region
rename s00q04 location
rename hgender sex
*poor already exists
gen wealth=.

*Access to healthcare
gen medicaltreatment=.
replace medicaltreatment=1 if s06q06==1
replace medicaltreatment=0 if s06q06==2

*Education
gen remotelearning=.
replace remotelearning=0 if s06q09__10==1
replace remotelearning=1 if s06q09__10==0
*replace remotelearning=1 if (s06q09__1==1 | s06q09__2==1 | s06q09__3==1 | s06q09__4==1 | s06q09__5==1 | s06q09__6==1 | s06q09__7==1 | s06q09__8==1 | s06q09__9==1)
*replace remotelearning=0 if (s06q09__1==0 & s06q09__2==0 & s06q09__3==0 & s06q09__4==0 & s06q09__5==0 & s06q09__6==0 & s06q09__7==0 & s06q09__8==0 & s06q09__9==0)
gen teacher=.
replace teacher=1 if s06q10==1
replace teacher=0 if s06q10==2

*Food security
foreach x in 1 2 3 4 5 6 7 8 {
replace s09q0`x'=. if s09q0`x'==98 | s09q0`x'==99
}
gen fies=.
replace fies=1 if s09q01==1 | s09q02==1 | s09q03==1
replace fies=2 if s09q04==1 | s09q05==1 | s09q06==1
replace fies=3 if s09q07==1 | s09q08==1
gen fsec=0
replace fsec=1 if fies==2 | fies==3

*Social protection
gen govtsupport=.		//Assistance from govt or other org over past month
replace govtsupport=1 if s05q21==1
replace govtsupport=0 if s05q21==2

*Regional attribution
gen regid=""
replace regid="TCD.2_1" if region==1
replace regid="TCD.3_1" if region==2
replace regid="TCD.4_1" if region==3
replace regid="TCD.7_1" if region==4
replace regid="TCD.8_1" if region==5
replace regid="TCD.9_1" if region==6
replace regid="TCD.10_1" if region==7
replace regid="TCD.11_1" if region==8
replace regid="TCD.12_1" if region==9
replace regid="TCD.13_1" if region==10
replace regid="TCD.14_1" if region==11
replace regid="TCD.15_1" if region==12
replace regid="TCD.16_1" if region==13
replace regid="TCD.17_1" if region==14
replace regid="TCD.18_1" if region==15
replace regid="TCD.20_1" if region==16
replace regid="TCD.23_1" if region==17
replace regid="TCD.22_1" if region==18
replace regid="TCD.1_1" if region==19
replace regid="TCD.6_1" if region==20
replace regid="TCD.19_1" if region==21
replace regid="TCD.5_1" if region==23

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid weight wealth poor medicaltreatment fsec remotelearning teacher govtsupport incomeloss month year
save "prep\TCD_wb_r1.dta", replace
