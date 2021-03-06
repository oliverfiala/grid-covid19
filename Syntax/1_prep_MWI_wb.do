*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUNDS 1-5 ---

forvalues r=1/5 {
*Prepare income loss file
if `r'!=5 {
	use "source\wb\MWI\sect7_income_loss_r`r'.dta", clear
	duplicates drop HHID, force
	gen incomeloss=.
	replace incomeloss=0 if s7q2==1 | s7q2==2		//Since mid-March (R1)/last call (R2-3-4)
	replace incomeloss=1 if s7q2==3
	tempfile sect7_income_loss_r`r'
	save `sect7_income_loss_r`r'', replace
}

*Open surveys and merge with income loss
if `r'!=4 {
	use "source\wb\MWI\sect11_safety_nets_r`r'.dta", clear 	//Safety nets
	duplicates list HHID
	duplicates drop HHID, force
	merge 1:1 HHID using "source\wb\MWI\sect8_food_security_r`r'.dta", nogen	//FSEC
	merge 1:1 HHID using "source\wb\MWI\secta_cover_page_r`r'.dta", nogen		//Disaggregation
}
if `r'==4 {
	use "source\wb\MWI\secta_cover_page_r`r'.dta", clear	//Disaggregation
}
if `r'!=5 {	
	merge 1:1 HHID using `sect7_income_loss_r`r'', nogen keepusing(incomeloss)		//Income loss
}
if 	`r'==5 {
	merge 1:m HHID using "source\wb\MWI\sect5c_education_r5.dta", nogen		//Education
	gen incomeloss=.
}
merge 1:1 HHID using "source\wb\MWI\sect5_access_r`r'.dta", nogen			//Health and education

*Weights
if `r'==1 {
	rename wt_baseline weight
	}
else {
	rename wt_round`r' weight
}

gen round=`r'
gen year=2020
gen month=.
if `r'==1 {
	replace month=6
}
if `r'==2 {
	replace month=7
}
if `r'==3 {
	replace month=8
}
if `r'==4 {
	replace month=10
}
if `r'==5 {
	replace month=11
}

*Prepare dataset by renaming & creating variables on interest
rename urb_rural location	//1 Urban 2 Rural
rename hh_a01 region
gen sex=.
gen wealth=.

*Health
gen natalcare=.
gen medicaltreatment=.
gen medicine=.
gen immunization=.
if `r'==1 | `r'==2 | `r'==5 {		
	replace medicaltreatment=1 if s5q4==1	//Since 20th March (R1)/last call (R2-5)
	replace medicaltreatment=0 if s5q4==2
	replace medicine=1 if s5q1b3==1			//Since 20th March (R1)/last week (R2-5)
	replace medicine=0 if s5q1b3==2
}
if `r'==3 | `r'==4 {
	replace natalcare=1 if s5q2_2b==1		//Since mid-March (R3)/last call (R4)
	replace natalcare=0 if s5q2_2b==2
	
	replace medicaltreatment=0 if s5q2_2e==1 | s5q2_2e==2		//Since mid-March(R3)/last week (R4)
	replace medicaltreatment=1 if s5q2_2e==3
	replace medicaltreatment=. if s5q2_2d==1
}
if `r'==4 {
	replace immunization=1 if s5q2_2k==1		//Since mid-March
	replace immunization=0 if s5q2_2k==2
}

*Education
gen schoolreturn=.
gen remotelearning=.
gen teacher=.
if `r'==1 | `r'==2 {				
	replace remotelearning=1 if s5q6d==1	//Past week
	replace remotelearning=0 if s5q6d==2
	replace teacher=1 if s5q7==1
	replace teacher=0 if s5q7==2
	}
if `r'==3 | `r'==4 {
	replace schoolreturn=1 if s5q17==1		//When schools reopen in September (R3)/since schools reopened on September 7 (R4)
	replace schoolreturn=0 if s5q17==2 | s5q17==3
}
if `r'==5 {
	replace teacher=1 if s5cq8==1
	replace teacher=0 if s5cq8==2
	replace schoolreturn=1 if s5cq1==1		//Are any of the children in your household currently going to school?
	replace schoolreturn=0 if s5cq1==2
}

*Nutrition (FIES scale http://www.fao.org/3/a-as583e.pdf)
gen fsec=.
if `r'!=4 {
	gen fies=0		//Past 30 days (R2: past 7 days according to report)
	*replace fies=0 if s8q1+s8q2+s8q3+s8q4+s8q5+s8q6+s8q7+s8q8==16	//None
	replace fies=1 if (s8q1==1 | s8q2==1 | s8q3==1) //Mild
	replace fies=2 if (s8q4==1 | s8q5==1 | s8q6==1) //Moderate
	replace fies=3 if (s8q7==1 | s8q8==1) //Severe
	replace fies=. if s8q1==.
	replace fsec=0 if fies==0 | fies==1
	replace fsec=1 if fies==2 | fies==3
}

*Social protection
gen govtsupport=.		//Any sort of assistance from any institution, timeframe: since 18th March (R1)/since last call (R2,3,5)
gen cashtransfer_delay=.		//Refers to difficulties accessing any assistance, not only cash transfers
if `r'!=4 {
	replace govtsupport=1 if s11q1==1
	replace govtsupport=0 if s11q1==2
	gen ngosupport=0
	replace ngosupport=1 if s11q1==1 & s11q3==3
}
if `r'!=1 & `r'!=4 {
	replace cashtransfer_delay=1 if s11q5==1
	replace cashtransfer_delay=0 if s11q5==2
	}
	
*Regional attribution
gen regid=""
replace region=105 if region==107	// Mzuzu city is part of Mzimba district
replace region=206 if region==210	// Lilongwe (both rural and urban)
replace region=303 if region==314	// Zomba (both rural and urban)
replace region=305 if region==315	// Blantyre (both rural and urban)
replace regid="MWI.5_1" if region==101
replace regid="MWI.8_1" if region==102
replace regid="MWI.19_1" if region==103
replace regid="MWI.25_1" if region==104
replace regid="MWI.17_1" if region==105
replace regid="MWI.9_1" if region==201
replace regid="MWI.20_1" if region==202
replace regid="MWI.23_1" if region==203
replace regid="MWI.7_1" if region==204
replace regid="MWI.26_1" if region==205
replace regid="MWI.11_1" if region==206
replace regid="MWI.14_1" if region==207
replace regid="MWI.6_1" if region==208
replace regid="MWI.22_1" if region==209
replace regid="MWI.13_1" if region==301
replace regid="MWI.12_1" if region==302
replace regid="MWI.28_1" if region==303
replace regid="MWI.4_1" if region==304
replace regid="MWI.2_1" if region==305
replace regid="MWI.16_1" if region==306
replace regid="MWI.27_1" if region==307
replace regid="MWI.15_1" if region==308
replace regid="MWI.24_1" if region==309
replace regid="MWI.3_1" if region==310
replace regid="MWI.21_1" if region==311
replace regid="MWI.1_1" if region==312
replace regid="MWI.18_1" if region==313

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth natalcare medicine medicaltreatment immunization fsec schoolreturn teacher remotelearning govtsupport incomeloss cashtransfer_delay weight round month year
save "prep\MWI_wb_r`r'.dta", replace
}
