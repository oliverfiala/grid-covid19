*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"


*--- ROUND 2 ---

use "source\wb\UGA\round2\SEC10.dta", clear
duplicates list HHID
duplicates drop HHID, force
merge 1:1 HHID using "source\wb\UGA\round2\SEC4.dta", nogen
merge 1:1 HHID using "source\wb\UGA\round2\SEC8.dta", nogen	
merge 1:1 HHID using "source\wb\UGA\round2\Cover.dta", nogen

*Weights
rename wfinal weight

*Prepare dataset by renaming & creating variables on interest
gen location=1
replace location=2 if urban==3
gen sex=.
rename region area
encode subreg, gen(region)
gen wealth=.

*Health
gen medicine=.
replace medicine=0 if s4q08==1
replace medicine=1 if s4q08==2
gen medicaltreatment=.
replace medicaltreatment=1 if s4q10==1
replace medicaltreatment=0 if s4q10==2

*Nutrition (FIES scale - 30 days - http://www.fao.org/3/a-as583e.pdf)
gen fies=1		//Mild
replace fies=0 if s8q01+s8q02+s8q03+s8q04+s8q05+s8q06+s8q07+s8q08==16
replace fies=2 if (s8q04==1 | s8q05==1 | s8q06==1) //Moderate
replace fies=3 if (s8q07==1 | s8q08==1) //Severe
gen fsec=0
replace fsec=1 if fies==2 | fies==3

*Social protection (round 2 timeframe: since last interview)
gen assistance=1
replace assistance=0 if s10q01==2
gen govtsupport=0
replace govtsupport=1 if s10q03__1==1
gen ngosupport=0
replace ngosupport=1 if s10q03__4==1

*Regional attribution
gen regid=""
replace regid="UGDHS2016452030" if region==1
replace regid="UGDHS2016452033" if region==2
replace regid="UGDHS2016452003" if region==3	// Buganda Nouth seems to be consistent with Central 2 in DHS shapefiles
replace regid="UGDHS2016452002" if region==4	// Buganda South seems to be consistent with Central 1 in DHS shapefiles
replace regid="UGDHS2016452026" if region==5
replace regid="UGDHS2016452031" if region==6
replace regid="UGDHS2016452025" if region==7
replace regid="UGDHS2016452027" if region==8	// Elgon seems to be Bugishu region
replace regid="UGDHS2016452004" if region==9
replace regid="UGDHS2016452012" if region==10
replace regid="UGDHS2016452034" if region==11
replace regid="UGDHS2016452029" if region==12
replace regid="UGDHS2016452028" if region==13
replace regid="UGDHS2016452032" if region==14
replace regid="UGDHS2016452009" if region==15

*Save
keep sex location region regid weight wealth medicine medicaltreatment fsec govtsupport
save "prep\UGA_wb_r2.dta", replace
