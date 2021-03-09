*Set working directory
cd "T:\PAC\Research\COVID-19\"

*--- ROUNDS 1-3 ---
*Drop duplicates
forvalues r=1/3 {
if `r'==1 {
	use "source\wb\KHM\Round_`r'\r1may2020_lsms_section07.dta", clear
	duplicates drop interview__key, force	
	tempfile r`r'_section07
	save `r`r'_section07', replace
	use "source\wb\KHM\Round_`r'\r1may2020_lsms_section11_2.dta", clear
	duplicates drop interview__key, force	
	tempfile r`r'_section11_2
	save `r`r'_section11_2', replace
}
if `r'==2 {
	use "source\wb\KHM\Round_`r'\r2august2020_lsms_section07.dta", clear
	duplicates drop interview__key, force	
	tempfile r`r'_section07
	save `r`r'_section07', replace
	use "source\wb\KHM\Round_`r'\r2august2020_lsms_section11_2.dta", clear
	duplicates drop interview__key, force	
	tempfile r`r'_section11_2
	save `r`r'_section11_2', replace
}
if `r'==3 {
	use "source\wb\KHM\Round_`r'\r3october2020_lsms_section07.dta", clear
	duplicates drop interview__key, force	
	tempfile r`r'_section07
	save `r`r'_section07', replace
	use "source\wb\KHM\Round_`r'\r3october2020_lsms_section11_2.dta", clear
	duplicates drop interview__key, force	
	tempfile r`r'_section11_2
	save `r`r'_section11_2', replace
}
*Open surveys
if `r'==1 {
	use "source\wb\KHM\Round_`r'\r1may2020_lsms_section00.dta", clear
	merge 1:1 interview__key using "source\wb\KHM\Round_`r'\r1may2020_lsms_section05.dta", nogen		//Health and education
}
if `r'==2 {
	use "source\wb\KHM\Round_`r'\r2august2020_lsms_section00.dta", clear
	merge 1:1 interview__key using "source\wb\KHM\Round_`r'\r2august2020_lsms_section02d.dta", nogen	//Disability
	merge 1:1 interview__key using "source\wb\KHM\Round_`r'\r2august2020_lsms_section05.dta", nogen		//Health and education
	merge 1:1 interview__key using "source\wb\KHM\Round_`r'\r2august2020_lsms_section08.dta", nogen		//Food insecurity
	merge 1:1 interview__key using "source\wb\KHM\Round_`r'\r2august2020_lsms_section02c.dta", nogen	//Wealth disaggregation (self-assessed)
}
if `r'==3 {
	use "source\wb\KHM\Round_`r'\r3october2020_lsms_section00.dta", clear
	merge 1:1 interview__key using "source\wb\KHM\Round_`r'\r3october2020_lsms_section05.dta", nogen		//Health and education
	merge 1:1 interview__key using "source\wb\KHM\Round_`r'\r3october2020_lsms_section08.dta", nogen		//Food insecurity
	merge 1:1 interview__key using "source\wb\KHM\Round_`r'\r3october2020_lsms_section02c.dta", nogen		//Wealth disaggregation (self-assessed)
}
merge 1:1 interview__key using `r`r'_section07', nogen		//Income loss
merge 1:1 interview__key using `r`r'_section11_2', nogen	//Social protection

*Weights
rename hhweight_adj weight

*Rounds
gen round=`r'

*Disaggregation
rename sector location		//1 urban 2 rural
rename s01q02 region
gen disability=.
gen poverty=.
gen sex=.

if `r'==1 {
	gen wealth=.
}

if `r'!=1 {
*How the household ranks in terms of social economic status compared to other households in the village?
	xtile wealth=s2cq2[aw=weight], n(5)		//August (R2) and October (R3) 2020		1 poorest 5 richest
}
if `r'==2 {
	replace disability=1 if s2dq1!=0
	replace disability=0 if s2dq1==0
}

*Health
gen medicine=.
if `r'==1 {
	replace medicine=0 if  s5q1a==1		//NB unable! Timeframe past week
	replace medicine=1 if  s5q1a==2
}
if `r'!=1{
	replace medicine=0 if  s5q1a==2		//NB able! Timeframe past week
	replace medicine=1 if  s5q1a==1
}
gen medicaltreatment=.
replace medicaltreatment=1 if s5q4==1
replace medicaltreatment=0 if s5q4==2		//Timeframe mid-March (R1)/last interview (R2-3)

*Nutrition - FIES scale http://www.fao.org/3/a-as583e.pdf		//No timeframe given
gen fsec=.
gen fies=.

if `r'!=1 {
	replace fies=0 if s8q1==2 & s8q2==2 & s8q3==2 & s8q4==2 & s8q5==2 & s8q6==2 & s8q7==2 & s8q8==2
	replace fies=1 if s8q1==1 | s8q2==1 | s8q3==1
	replace fies=2 if s8q4==1 | s8q5==1 | s8q6==1
	replace fies=3 if s8q7==1 | s8q8==1
	replace fsec=0 if fies==0 | fies==1
	replace fsec=1 if fies==2 | fies==3
}

*Education
gen remotelearning=.
gen teacher=.
replace remotelearning=1 if s5q6b==1		//Timeframe past week
replace remotelearning=0 if s5q6b==2
replace teacher=1 if s5q7==1
replace teacher=0 if s5q7==2		//Timeframe past week

*Social protection
gen govtsupport=.
replace govtsupport=1 if s11q1==1		//Refers to assistance from any institution, not only the government; timeframe since the COVID-19 outbreak (R1)/last interview (i.e. May; R2)
replace govtsupport=0 if s11q1==2

*Income loss
gen incomeloss=.		//Timeframe since outbreak (R1)/last interview (R2-3)
replace incomeloss=1 if s7q2==3
replace incomeloss=0 if s7q2==1 | s7q2==2
	
*Regional attribution
gen regid=""
replace regid="KH.01" if region==1
replace regid="KH.0224" if region==2 | region==24
replace regid="KH.03" if region==3 | region==25		//Tboung Khmum Province still considered part of Kampong Cham, from which it was separated in 2013
replace regid="KH.04" if region==4
replace regid="KH.05" if region==5
replace regid="KH.06" if region==6
replace regid="KH.0723" if region==7		//Kampot includes Kep
replace regid="KH.08" if region==8
replace regid="KH.0918" if region==9 | region==18
replace regid="KH.10" if region==10
replace regid="KH.1116" if region==11 | region==16
replace regid="KH.12" if region==12
replace regid="KH.1319" if region==13 | region==19
replace regid="KH.14" if region==14
replace regid="KH.15" if region==15
replace regid="KH.17" if region==17
replace regid="KH.20" if region==20
replace regid="KH.21" if region==21
replace regid="KH.22" if region==22

*Save
keep round location region disability sex wealth poverty regid medicine medicaltreatment fsec remotelearning teacher govtsupport incomeloss weight
save "prep\KHM_wb_r`r'.dta", replace
}
