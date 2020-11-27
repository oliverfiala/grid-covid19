*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"


*--- ROUND 3 ---

use "source\wb\MWI\sect11_safety_nets_r3.dta", clear
duplicates list HHID
duplicates drop HHID, force
merge 1:1 HHID using "source\wb\MWI\sect5_access_r3.dta", nogen			//Access
merge 1:1 HHID using "source\wb\MWI\sect8_food_security_r3.dta", nogen	//FSEC
merge 1:1 HHID using "source\wb\MWI\secta_cover_page_r3.dta", nogen		//Safety nets

*Weights
rename wt_round3 weight

*Prepare dataset by renaming & creating variables on interest
rename urb_rural location	//1 Urban 2 Rural
rename hh_a01 region
gen sex=.
gen wealth=.

*Health
gen natalcare=.
replace natalcare=1 if s5q2_2b==1
replace natalcare=0 if s5q2_2b==2
gen medicaltreatment=.
replace medicaltreatment=0 if s5q2_2e==1 | s5q2_2e==2
replace medicaltreatment=1 if s5q2_2e==3
replace medicaltreatment=. if s5q2_2d==1

*Education
gen schoolreturn=.
replace schoolreturn=1 if s5q17==1
replace schoolreturn=0 if s5q17==2 | s5q17==3

*Nutrition (FIES scale http://www.fao.org/3/a-as583e.pdf)
gen fies=0		//Past 30 days R1; R2: past 7 days according to report; past 30 days according to questionnaire
*replace fies=0 if s8q1+s8q2+s8q3+s8q4+s8q5+s8q6+s8q7+s8q8==16	//None
replace fies=1 if (s8q1==1 | s8q2==1 | s8q3==1) //Mild
replace fies=2 if (s8q4==1 | s8q5==1 | s8q6==1) //Moderate
replace fies=3 if (s8q7==1 | s8q8==1) //Severe
replace fies=. if s8q1==.
gen fsec=.
replace fsec=0 if fies==0 | fies==1
replace fsec=1 if fies==2 | fies==3

*Social protection
gen govtsupport=.		//Any sort of assistance from any institution, timeframe: since last call
replace govtsupport=1 if s11q1==1
replace govtsupport=0 if s11q1==2
gen ngosupport=0
replace ngosupport=1 if s11q1==1 & s11q3==3

*Regional attribution
gen regid=""
replace region=105 if region==107	// Mzuzu city is part of Mzimba district
replace region=206 if region==210	// Lilongwe (both rural and urban)
replace region=303 if region==314	// Zomba (both rural and urban)
replace region=305 if region==315	// Blantyre (both rural and urban)
replace regid="MW.CT" if region==101
replace regid="MW.KR" if region==102
replace regid="MW.NA" if region==103
replace regid="MW.RU" if region==104
replace regid="MW.MZ" if region==105
replace regid="MW.KS" if region==201
replace regid="MW.NK" if region==202
replace regid="MW.NI" if region==203
replace regid="MW.DO" if region==204
replace regid="MW.SA" if region==205
replace regid="MW.LI" if region==206
replace regid="MW.MC" if region==207
replace regid="MW.DE" if region==208
replace regid="MW.NU" if region==209
replace regid="MW.MG" if region==301
replace regid="MW.MH" if region==302
replace regid="MW.ZO" if region==303
replace regid="MW.CR" if region==304
replace regid="MW.BL" if region==305
replace regid="MW.MW" if region==306
replace regid="MW.TH" if region==307
replace regid="MW.MJ" if region==308
replace regid="MW.PH" if region==309
replace regid="MW.CK" if region==310
replace regid="MW.NS" if region==311
replace regid="MW.BA" if region==312
replace regid="MW.NN" if region==313

*Save
keep sex location region regid wealth natalcare medicaltreatment fsec schoolreturn govtsupport weight
save "prep\MWI_wb_r3.dta", replace
