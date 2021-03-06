*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUNDS 1-5 ---

*Prepare social protection file for R3 and R5
forvalues r=3(2)5 {
	use "source\wb\BFA\r`r'_sec10_protection_sociale.dta", clear
	duplicates drop hhid, force	
	gen govtsupport=.
	replace govtsupport=1 if s10q01==1		//Assistance from any institution (not only govt) since March 2020 (R3)/last interview (R5) 
	replace govtsupport=0 if s10q01==2
	tempfile r`r'_sec10_protection_sociale
	save `r`r'_sec10_protection_sociale', replace
}

*Open surveys
forvalues r=1/5 {
use "source\wb\BFA\r`r'_sec0_cover.dta", clear
merge 1:1 hhid using "source\wb\BFA\r`r'_sec5_acces_service_base.dta", nogen	//Health, education
if `r'==1 {
	merge 1:1 hhid using "source\wb\BFA\r1_sec6_emploi_revenue.dta", nogen	//Income
	}
else {
	merge 1:1 hhid using "source\wb\BFA\r`r'_sec7_securite_alimentaire.dta", nogen	//Food security
}
if `r'==2 {
	merge 1:1 hhid using "source\wb\BFA\r2_sec6e_emplrev_transferts.dta", nogen	//Safety nets
	}
if `r'==3 | `r'==5 {
	merge 1:1 hhid using `r`r'_sec10_protection_sociale', nogen keepusing (govtsupport) //Safety nets
}
if `r'==5 {
	merge 1:m hhid using "source\wb\BFA\r5_sec5e_education.dta", nogen		// Education
}

gen round=`r'
gen year=2020
gen month=.
if `r'==1 {
	replace month=7
}
if `r'==2 {
	replace month=8
}
if `r'==3 {
	replace month=10
}
if `r'==4 {
	replace month=11
}
if `r'==5 {
	replace month=12
}

*Weights
if `r'==1 {
	rename hhwcovid_r`r' weight
}
if `r'==2 {
	rename hhwcovid_r2_s1s2 weight
}
if `r'>=3 {
	rename hhwcovid_r`r'_cs weight
}

*Prepare dataset by renaming & creating variables of interest
rename milieu location	//1 urban 2 rural
gen gender=.
gen wealth=.
gen sex=.
*region is already there

if `r'==1 {
	gen poor=.
	}
else {
rename b40 poor
}

*Health
gen medicine=.
gen medicaltreatment=.
gen natalcare=.

if `r'==1 {
	replace medicine=1 if s05q01==1
	replace medicine=0 if s05q01==2
}
else {
	replace medicine=1 if s05q01a==1 | s05q01a==2 | s05q01a==3		// Past 7 days
	replace medicine=0 if s05q01a==4
	replace medicine=. if s05q01a==5
}
if `r'!=1 {
	replace medicaltreatment=1 if s05q03d==1		//Past 7 days
	replace medicaltreatment=0 if s05q03d==2
	}
	
if `r'==5 {
	replace natalcare=1 if s05q03_2==1
	replace natalcare=0 if s05q03_2==2
}

*Nutrition
gen basicfood=.
gen fies=.
gen fsec=.
if `r'==1 {
	*Nutrition (basic foods)
	replace basicfood=1
	replace basicfood=0 if (s05q02a==2 | s05q02c==2 | s05q02e==2)
	replace basicfood=. if (s05q02a==3 & s05q02c==3 & s05q02e==3)
}
*Nutrition - FIES scale http://www.fao.org/3/a-as583e.pdf - no timeframe given
if 	`r'>=4 {
	replace fies=0 if s07q01==2 & s07q02==2 & s07q03==2 & s07q04==2 & s07q05==2 & s07q06==2 & s07q07==2 & s07q08==2
}
if `r'==2 | `r'==3 {
	replace fies=0 if s07q01==0 & s07q02==0 & s07q03==0 & s07q04==0 & s07q05==0 & s07q06==0 & s07q07==0 & s07q08==0
}
if `r'!=1 {
	replace fies=1 if s07q01==1 | s07q02==1 | s07q03==1
	replace fies=2 if s07q04==1 | s07q05==1 | s07q06==1
	replace fies=3 if s07q07==1 | s07q08==1
	replace fsec=0 if fies==0 | fies==1
	replace fsec=1 if fies==2 | fies==3
}

*Education
gen teacher=.
gen remotelearning=.
if `r'<=2 {
	replace teacher=1 if s05q07==1
	replace teacher=0 if s05q07==2
	replace remotelearning=1 if s05q06__14==0
	replace remotelearning=0 if s05q06__14==1
	*replace remotelearning=1 if s05q06__1==1 | s05q06__2==1 | s05q06__3==1 | s05q06__4==1 | s05q06__5==1 | s05q06__6==1 | s05q06__7==1 | s05q06__8==1 | s05q06__9==1 | s05q06__10==1 | s05q06__11==1 | s05q06__12==1 | s05q06__13==1
	*replace remotelearning=0 if s05q06__1==0 & s05q06__2==0 & s05q06__3==0 & s05q06__4==0 & s05q06__5==0 & s05q06__6==0 & s05q06__7==0 & s05q06__8==0 & s05q06__9==0 & s05q06__10==0 & s05q06__11==0 & s05q06__12==0 & s05q06__13==0
}
if `r'==2 {
	replace remotelearning=. if s05q06__15==1
}
if `r'==5 {
	replace remotelearning=1 if s05eq01==1		//Whether children are attending school remotely or in person during the academic year 2020/2021
	replace remotelearning=0 if s05eq01==2
}

*Social protection
gen incomeloss=.
if `r'==1 {
	gen govtsupport=.
	replace incomeloss=1 if s06q12==3 | s06q12==4	//Income from family enterprise decreased or was null compared to before 16 March
	replace incomeloss=0 if s06q12==1 | s06q12==2
}
if `r'==2 {
	gen govtsupport=.					//Assistance from any institution/organization (not only govt) since last call
	replace govtsupport=1 if s06q23==1 & s06q26==1
	replace govtsupport=0 if s06q23==2 /*| (s06q23==1 & s06q26!=1)*/		//Assistance from govt only
}
if `r'==4 {
	gen govtsupport=.
}

*Regional attribution
gen regid=""
replace regid="BFA.1_1" if region==1
replace regid="BFA.2_1" if region==2
replace regid="BFA.7_1" if region==3
replace regid="BFA.3_1" if region==4
replace regid="BFA.4_1" if region==5
replace regid="BFA.5_1" if region==6
replace regid="BFA.6_1" if region==7
replace regid="BFA.8_1" if region==8
replace regid="BFA.9_1" if region==9
replace regid="BFA.10_1" if region==10
replace regid="BFA.11_1" if region==11
replace regid="BFA.12_1" if region==12
replace regid="BFA.13_1" if region==13

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth poor medicine medicaltreatment natalcare fsec basicfood remotelearning teacher govtsupport incomeloss weight round month year
save "prep\BFA_wb_r`r'.dta", replace
}
