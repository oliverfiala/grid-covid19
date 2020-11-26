*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*--- ROUND 1 ---

use "source\wb\TCD\round01_assistance.dta", clear
duplicates list hhid interview__key interview__id
duplicates drop hhid interview__key interview__id, force
merge 1:1 hhid using "source\wb\TCD\round01_household.dta", nogen

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
gen govtsupport=.		//Assistance from govt or other org over past month!
replace govtsupport=1 if s05q21==1
replace govtsupport=0 if s05q21==2

*Regional attribution
gen regid=""
replace regid="TD.BA" if region==1
replace regid="TD.BR" if region==2
replace regid="TD.CB" if region==3
replace regid="TD.GR" if region==4
replace regid="TD.HD" if region==5
replace regid="TD.KM" if region==6
replace regid="TD.LC" if region==7
replace regid="TD.LO" if region==8
replace regid="TD.LR" if region==9
replace regid="TD.MA" if region==10
replace regid="TD.ME" if region==11
replace regid="TD.MW" if region==12
replace regid="TD.MC" if region==13
replace regid="TD.OA" if region==14
replace regid="TD.SA" if region==15
replace regid="TD.TA" if region==16
replace regid="TD.BI" if region==17
replace regid="TD.NJ" if region==18
replace regid="TD.BG" if region==19
replace regid="TD.EO" if region==20
replace regid="TD.SI" if region==21
replace regid="TD.EE" if region==23

*Save
keep sex location region regid wealth poor medicaltreatment fsec remotelearning teacher govtsupport
save "prep\TCD_wb_r1.dta", replace
