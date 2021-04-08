*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUNDS 1-7 ---
forvalues r=1/7 {
if `r'==1 {
	use "source\wb\NGA\r1_sect_7.dta", clear
	duplicates drop hhid, force
	gen incomeloss=.
	replace incomeloss=1 if s7q2==3
	replace incomeloss=0 if s7q2==1 | s7q2==2
	tempfile r4_sect_7
	save `r4_sect_7', replace
	use "source\wb\NGA\r1_sect_11.dta", clear	//Safety nets
	duplicates drop hhid, force
	merge 1:1 hhid using "source\wb\NGA\r1_sect_a_3_4_5_6_8_9_12.dta", nogen		//Education, health, food security
	merge 1:1 hhid using `r4_sect_7', nogen	keepusing(incomeloss)	//Income loss
}
if `r'==2 {
	use "source\wb\NGA\r2_sect_11.dta", clear		//Safety nets
	duplicates drop hhid, force
	gen incomeloss=.
	merge 1:1 hhid using "source\wb\NGA\r2_sect_a_2_5_6_8_12.dta", nogen	//Health, education, food security
}
if `r'==3{
	use "source\wb\NGA\r3_sect_11.dta", clear		//Safety nets
	duplicates drop hhid, force
	gen incomeloss=.
	merge 1:1 hhid using "source\wb\NGA\r3_sect_a_2_5_5a_6_12.dta", nogen	//Health, education
}
if `r'==4 {
	*Prepare income loss file
	use "source\wb\NGA\r4_sect_7.dta", clear
	duplicates drop hhid, force
	gen incomeloss=0 if s7q2<=2		//Compared to same time last year
	replace incomeloss=1 if s7q2>=3
	tempfile r4_sect_7
	save `r4_sect_7', replace

	*Open surveys and merge with income loss
	use "source\wb\NGA\r4_sect_11.dta", clear
	duplicates list hhid
	duplicates drop hhid, force
	merge 1:1 hhid using "source\wb\NGA\r4_sect_a_2_5_5b_6_8_9_12.dta", nogen
	merge 1:1 hhid using `r4_sect_7', nogen	keepusing(incomeloss)
}
if `r'==5 {
	use "source\wb\NGA\r5_sect_a_2_5c_6_12.dta", clear
	gen incomeloss=.
}
if `r'==6 {
	use "source\wb\NGA\r6_sect_1.dta", clear
	duplicates drop hhid, force
	merge 1:1 hhid using "source\wb\NGA\r6_sect_a_2_3a_6_9a_12.dta", nogen keepusing(wt_round6 wt_r6panel)
	merge 1:m hhid using "source\wb\NGA\r6_sect_5c.dta", nogen
	gen incomeloss=.
}
if `r'==7 {
	use "source\wb\NGA\r7_sect_11.dta", clear	//Disaggregation + safety nets
	duplicates drop hhid, force
	merge 1:1 hhid using "source\wb\NGA\r7_sect_a_5_6_8_9_12.dta", nogen
	gen incomeloss=.
}

*Weights
gen weight_edu=.
if `r'==1 {
	rename wt_baseline weight
}
else {
	rename wt_round`r' weight
}
if `r'==6 {
	replace weight_edu=wt_educ_r6
}

gen round=`r'
gen month=.
if `r'==1 {
replace month=5
}
if `r'==2 {
replace month=6
}
if `r'==3 {
replace month=7
}
if `r'==4 {
replace month=8
}
if `r'==5 {
replace month=9
}
if `r'==6 {
replace month=10
}
if `r'==7 {
replace month=11
}
gen year=2020

*Prepare dataset by renaming & creating variables on interest
rename sector location		//1 urban 2 rural
*rename state region
gen sex=.
if `r'<6 | `r'==7 {
	merge 1:1 hhid using "source\NGA_2020_NLPS_v01_M_v01_A_COVID_Stata\nga_hh.dta", nogen keepusing(cons_quint zone) keep(1 3)
}
if `r'==6 {
	merge m:1 hhid using "source\NGA_2020_NLPS_v01_M_v01_A_COVID_Stata\nga_hh.dta", nogen keepusing(cons_quint zone) keep(1 3)
}
gen wealth=cons_quint
ren zone region
if `r'==6 {
	merge 1:1 hhid indiv using "source\NGA_2020_NLPS_v01_M_v01_A_COVID_Stata\nga_ind.dta", nogen keepusing(disability) keep(1 3)
}
cap gen disability=. 

*Health
gen medicine=.
gen natalcare=.
gen immunization=.
gen medicaltreatment=.	//Since mid-March (R1), past 7 days (R2, R3, R4)
if `r'==1 {
	replace medicine=1 if s5q1b1==1		//Past 7 days
	replace medicine=0 if s5q1b1==2
	}
if `r'==3 {
	replace immunization=1 if s5q3b==1
	replace immunization=0 if s5q3b==2
}
if `r'==4 {
	replace natalcare=1 if s5q2b==1
	replace natalcare=0 if s5q2b==2
}
if `r'<5 {
	replace medicaltreatment=1 if s5q3==1
	replace medicaltreatment=0 if s5q3==2
}

*Food security
gen fies=.
gen fsec=.
if `r'==1 {
	replace fsec=1 if s8q4==1 | s8q6==1 | s8q8==1
	replace fsec=0 if s8q4==2 & s8q6==2 & s8q8==2
}
if `r'==2 | `r'==4 | `r'==7 {
	replace fies=0 if s8q1==2 & s8q2==2 & s8q3==2 & s8q4==2 & s8q5==2 & s8q6==2 & s8q7==2 & s8q8==2
	replace fies=1 if s8q1==1 | s8q2==1 | s8q3==1
	replace fies=2 if s8q4==1 | s8q5==1 | s8q6==1
	replace fies=3 if s8q7==1 | s8q8==1
	replace fsec=0 if fies==0 | fies==1
	replace fsec=1 if fies==2 | fies==3
}

*Education
gen teacher=.
gen schoolreturn=.
gen schoolattendance=.
gen remotelearning=.
if `r'==1 | `r'==2 {
	replace teacher=1 if s5q6==1
	replace teacher=0 if s5q6==2
}
if `r'==4 {
	replace schoolreturn=1 if s5q5c==1
	replace schoolreturn=0 if s5q5c==2 | s5q5c==3
	replace schoolattendance=1 if s5q5b==1
	replace schoolattendance=0 if s5q5b==2
}
if `r'==5 {
	replace teacher=1 if s5cq8==1
	replace teacher=0 if s5cq8==2
	replace remotelearning=1 if s5cq6==1	//Past 7 days
	replace remotelearning=0 if s5cq6==2
	replace schoolattendance=1 if s5cq1==1
	replace schoolattendance=0 if s5cq1==2
}
if `r'<5 {
	replace remotelearning=1 if s5q4b==1	//Past 7 days
	replace remotelearning=0 if s5q4b==2
}
if `r'==6 {
	replace schoolattendance=1 if s5cq11==1		//Currently attending school either in person or remotely
	replace schoolattendance=0 if s5cq11==2
	replace remotelearning=1 if s5cq21==1		//Engaged in remote learning activities after schools closed in mid-March
	replace remotelearning=0 if s5cq21==2
	replace schoolreturn=1 if s5cq12a==1		//Plans to return to school when schools reopen
	replace schoolreturn=0 if s5cq12a==2
}

*Social protection
gen govtsupport=.		//Since mid-March (R1)/last interview (R2-R4)
gen cashtransfer_delay=.	// Refers to difficulties accessing any kind of assistance, not only cash transfers
if `r'==1 {
	replace govtsupport=0
	replace govtsupport=1 if s11q1==1 & (s11q3==1 | s11q3==2 | s11q3==3)
	}
if `r'!=1 & `r'!=5  & `r'!=6 {
	replace govtsupport=0
	replace govtsupport=1 if s11q1==1 & ( s11q3__1==1 | s11q3__2==1 | s11q3__3==1)
}
if `r'==2 | `r'==3 | `r'==7 {
	replace cashtransfer_delay=1 if s11q5==1
	replace cashtransfer_delay=0 if s11q5==2
	}

*Regional attribution
gen regid=""
/*
replace regid="NGA.1_1" if region==1
replace regid="NGA.2_1" if region==2
replace regid="NGA.3_1" if region==3
replace regid="NGA.4_1" if region==4
replace regid="NGA.5_1" if region==5
replace regid="NGA.6_1" if region==6
replace regid="NGA.7_1" if region==7
replace regid="NGA.8_1" if region==8
replace regid="NGA.9_1" if region==9
replace regid="NGA.10_1" if region==10
replace regid="NGA.11_1" if region==11
replace regid="NGA.12_1" if region==12
replace regid="NGA.13_1" if region==13
replace regid="NGA.14_1" if region==14
replace regid="NGA.16_1" if region==15
replace regid="NGA.17_1" if region==16
replace regid="NGA.18_1" if region==17
replace regid="NGA.19_1" if region==18
replace regid="NGA.20_1" if region==19
replace regid="NGA.21_1" if region==20
replace regid="NGA.22_1" if region==21
replace regid="NGA.23_1" if region==22
replace regid="NGA.24_1" if region==23
replace regid="NGA.25_1" if region==24
replace regid="NGA.26_1" if region==25
replace regid="NGA.27_1" if region==26
replace regid="NGA.28_1" if region==27
replace regid="NGA.29_1" if region==28
replace regid="NGA.30_1" if region==29
replace regid="NGA.31_1" if region==30
replace regid="NGA.32_1" if region==31
replace regid="NGA.33_1" if region==32
replace regid="NGA.34_1" if region==33
replace regid="NGA.35_1" if region==34
replace regid="NGA.36_1" if region==35
replace regid="NGA.37_1" if region==36
replace regid="NGA.15_1" if region==37
*/
replace regid="NGDHS2013433005" if region==1	// North Central
replace regid="NGDHS2013433006" if region==2	// North East
replace regid="NGDHS2013433007" if region==3	// North West
replace regid="NGDHS2013433009" if region==6	// South West
replace regid="NGDHS2013433008" if region==4	// South East
replace regid="NGDHS2013433010" if region==5	// South South

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth disability weight weight_edu natalcare medicine medicaltreatment fsec remotelearning schoolreturn schoolattendance teacher govtsupport cashtransfer_delay incomeloss round month year
save "prep\NGA_wb_r`r'.dta", replace
}
