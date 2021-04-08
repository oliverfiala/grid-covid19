*Set working directory
cd "T:\PAC\Research\COVID-19\"

*--- ROUND 1 ---

*Open survey
use "source\wb\VNM\sec4.dta", clear		//Education
duplicates drop hhid2, force
tempfile sec4
save `sec4', replace
use "source\wb\VNM\sec7.dta", clear		//Safety nets
duplicates drop hhid2, force
merge 1:1 hhid2 using "source\wb\VNM\main.dta", nogen		//Health
merge 1:1 hhid2 using `sec4', nogen

gen round=1
gen month=7
gen year=2020

*Weights
*variable weight already named weight

*Disaggregation and variables of interest
rename urban_rural location
rename reg6 region
gen wealth=.
gen poor=.
gen sex=.

*Health
gen medicine=.

gen medicaltreatment=.
replace medicaltreatment=1 if s3q2==1
replace medicaltreatment=0 if s3q2==2

gen immunization=.
replace immunization=1 if s3q5==1		//Child under 5 taken to immunization centre over past 3 months
replace immunization=0 if s3q5==2

gen natalcare=.
replace natalcare=1 if s3q8==1		//Pregnant woman/woman who just gave birth visited health facility or antenatal care over past 3 months
replace natalcare=0 if s3q8==2

*Nutrition (FIES scale http://www.fao.org/3/a-as583e.pdf)
gen fsec=.
replace fsec=1 if s8q1==1		//Mild food insecurity according to FIES scale
replace fsec=0 if s8q1==2

*Education
gen schoolstop=.
replace schoolstop=1 if s4q5==1		//Pupil stopped attending classes due to school closures
replace schoolstop=0 if s4q5==0

gen remotelearning=.
replace remotelearning=1 if s4q6==1		//Engagement in any education activity during school closures
replace remotelearning=0 if s4q6==2

gen schoolreturn=.
replace schoolreturn=1 if s4q11==1		//Pupil still enrolled in school
replace schoolreturn=0 if s4q11==2

*Social protection
gen incomeloss=.
replace incomeloss=1 if s6q1==1		//Family experienced episode of income reduction since Feb 2020
replace incomeloss=0 if s6q1==2

gen govtsupport=.
replace govtsupport=1 if s7q5==1		//Household received support from the government since February
replace govtsupport=0 if s7q5==2

*Regional attribution
gen regid=""
replace regid="VN.RR1" if region==1
replace regid="VN.NM1" if region==2
replace regid="VN.CC1" if region==3
replace regid="VN.CH1" if region==4
replace regid="VN.SE1" if region==5
replace regid="VN.MR1" if region==6

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth poor medicine medicaltreatment immunization natalcare remotelearning schoolreturn schoolstop fsec govtsupport incomeloss weight month year
save "prep\VNM_wb_r1.dta", replace
