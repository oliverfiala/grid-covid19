*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"
/*
*--- ROUND 1 ---

use "source\wb\BFA\r1_sec0_cover.dta", clear
merge 1:1 hhid using "source\wb\BFA\r1_sec5_acces_service_base.dta", nogen	//Services

*Weights
rename hhwcovid_r1 weight

*1. Prepare dataset by renaming & creating variables on interest
rename milieu location	//1 urban 2 rural
gen gender=.
gen poor=.
gen wealth=.
gen sex=.
*region is already there

*Health
gen medicine=.
replace medicine=1 if s05q01==1
replace medicine=0 if s05q01==2

gen medicaltreatment=.
replace medicaltreatment=1 if s05q03d==1
replace medicaltreatment=0 if s05q03d==2

*Education
gen teacher=.
replace teacher=1 if s05q07==1
replace teacher=0 if s05q07==2

gen remotelearning=.
replace remotelearning=1 if s05q06__14==0
replace remotelearning=0 if s05q06__14==1

*Nutrition (basic foods)
gen basicfood=1
replace basicfood=0 if (s05q02a==2 | s05q02c==2 | s05q02e==2)
replace basicfood=. if (s05q02a==3 & s05q02c==3 & s05q02e==3)

*Regional attribution
gen regid=""
replace regid="BF.BO" if region==1
replace regid="BF.CD" if region==2
replace regid="BF.CT" if region==3
replace regid="BF.CE" if region==4
replace regid="BF.CN" if region==5
replace regid="BF.CO" if region==6
replace regid="BF.CS" if region==7
replace regid="BF.ES" if region==8
replace regid="BF.HB" if region==9
replace regid="BF.NO" if region==10
replace regid="BF.PC" if region==11
replace regid="BF.SA" if region==12
replace regid="BF.SO" if region==13

*Save
keep sex location region regid wealth poor medicine medicaltreatment basicfood remotelearning teacher
save "prep\BFA_wb_r1.dta", replace
*/

*--- ROUND 2 ---

*Open survey
use "source\wb\BFA\r2_sec0_cover.dta", clear
merge 1:1 hhid using "source\wb\BFA\r2_sec5_acces_service_base.dta", nogen	//Services
merge 1:1 hhid using "source\wb\BFA\r2_sec7_securite_alimentaire.dta", nogen	//FSEC
merge 1:1 hhid using "source\wb\BFA\r2_sec6e_emplrev_transferts.dta", nogen	//Safety nets

*Weights
rename hhwcovid_r2_s1s2 weight

*Prepare dataset by renaming & creating variables on interest
rename milieu location	//1 urban 2 rural
gen sex=.
rename b40 poor
*region is already there
gen wealth=.

*Health
gen medicine=1
replace medicine=0 if s05q01a==4
replace medicine=. if s05q01a==5
gen medicaltreatment=.
replace medicaltreatment=1 if s05q03d==1
replace medicaltreatment=0 if s05q03d==2

*Nutrition - FIES scale http://www.fao.org/3/a-as583e.pdf - no timeframe given
gen fies=.
replace fies=0 if s07q01==0 & s07q02==0 & s07q03==0 & s07q04==0 & s07q05==0 & s07q06==0 & s07q07==0 & s07q08==0
replace fies=1 if s07q01==1 | s07q02==1 | s07q03==1
replace fies=2 if s07q04==1 | s07q05==1 | s07q06==1
replace fies=3 if s07q07==1 | s07q08==1
gen fsec=0
replace fsec=1 if fies==2 | fies==3

*Education
gen remotelearning=.
replace remotelearning=1 if s05q06__14==0
replace remotelearning=0 if s05q06__14==1
gen teacher=.
replace teacher=1 if s05q07==1
replace teacher=0 if s05q07==2

*Social protection
gen govtsupport=.		//Timeframe since last call; definition aid from govt or other institutions, to technically "assistance"
replace govtsupport=1 if s06q23==1
replace govtsupport=0 if s06q23==2
gen assistance=govtsupport

*Regional attribution
gen regid=""
replace regid="BF.BO" if region==1
replace regid="BF.CD" if region==2
replace regid="BF.CT" if region==3
replace regid="BF.CE" if region==4
replace regid="BF.CN" if region==5
replace regid="BF.CO" if region==6
replace regid="BF.CS" if region==7
replace regid="BF.ES" if region==8
replace regid="BF.HB" if region==9
replace regid="BF.NO" if region==10
replace regid="BF.PC" if region==11
replace regid="BF.SA" if region==12
replace regid="BF.SO" if region==13

*Save
keep sex location region regid wealth poor medicine medicaltreatment fsec remotelearning teacher govtsupport
save "prep\BFA_wb_r2.dta", replace
