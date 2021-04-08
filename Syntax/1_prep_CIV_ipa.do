*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUNDS 1-2 ---
forvalues r=1/2 {

*Open survey
if `r'==1 {
	use "source\ipa\CDI_RECOVR_round1.dta", clear
}
if `r'==2 {
	use "source\ipa\CDI_RECOVR_R2.dta", clear
	destring caseid, replace force
	merge 1:1 caseid using "source\ipa\CDI_RECOVR_round1.dta", nogen keepusing(dem1 dem2 dem3 PPI) keep(match master)
}

*Disaggregation
rename dem1 age
rename dem2 sex		//Male 1 female 2
if `r'==2 {
	rename region reg
}
rename dem3 region
if `r'==2 {
	replace region=. if dem6==1		//Can't ascertain where household moved
}
gen location=.
if `r'==1 {
	drop gender
	rename dem10a primary
	rename dem10b secondary
	gen schoolchildren=0
	replace schoolchildren=1 if primary>0 | secondary>0
	rename dem11 education
}

*Wealth disaggregation: create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)

gen round=1
gen year=2020
if `r'==1 {
	gen month=7
}
else {
	gen month=10
}

*Variables
gen incomeloss=.
gen teacher=.
gen remotelearning=.
if `r'==1 {
	rename hlth4 healthseeking		//Timeframe: mid-March

	rename fsec1 mealsize
	replace mealsize=. if mealsize==-888 | mealsize==-999
	rename fsec2 mealnumber
	replace mealnumber=. if mealnumber==-888 | mealnumber==-999
	gen mealsize_bin=.
	replace mealsize_bin=0 if mealsize==0
	replace mealsize_bin=1 if mealsize>0 & mealsize<8
	gen mealnumber_bin=.
	replace mealnumber_bin=0 if mealnumber==0
	replace mealnumber_bin=1 if mealnumber>0 & mealnumber<8

	gen fsec=.
	replace fsec=0 if (mealsize_bin==0 & mealnumber_bin==0)
	replace fsec=1 if (mealsize_bin==1 | mealnumber_bin==1)

	rename edu2 remotelearning_primary
	rename edu3 remotelearning_secondary
	rename edu10b schoolreturn

	rename net1 cashtransfer
	rename net2 cashtransfer_delay		// delay or difficulty

	replace incomeloss=1 if inc9==3		//Over the past 7 days, compared to before the government closed the schools
	replace incomeloss=0 if inc9==1 | inc9==2
	
	rename net3 govtsupport		//Timeframe last month (R1-2)
}
if `r'==2 {
	rename hlth4c healthseeking //Children in the household skip, delay, or unable to access health care services since June
	replace healthseeking=. if healthseeking==-999 //1 Disruption 0 No disruption
	replace healthseeking=0 if hlth4b==0
	
	gen fsec=.		//Children in the household, past 7 days
	replace fsec=1 if fsec1b>0 | fsec2b>0
	replace fsec=0 if fsec1b==0 & fsec2b==0
	
	replace teacher=edu28_1			//Teacher has stayed in touch with at least 1 child in the household during lockdown
	replace teacher=. if teacher==-999
	
	replace remotelearning=1 if edu35_0==0		//Children in the household have used education support(s) to continue their studies between June and the start of the new school year
	replace remotelearning=0 if edu35_0==1
	
	gen schoolreturn=0		//All school children in the household have resumed schooling
	replace schoolreturn=1 if (edu21c_1==1 | edu21c_1==.) & (edu21d_1==1 | edu21d_1==.) & (edu21c_2==1 | edu21c_2==.) & (edu21d_2==1 | edu21d_2==.) & (edu21c_3==1 | edu21c_3==.) & (edu21d_3==1 | edu21d_3==.) & (edu21c_4==1 | edu21c_4==.) & (edu21d_4==1 | edu21d_4==.) & (edu21c_5==1 | edu21c_5==.) & (edu21d_5==1 | edu21d_5==.)
	replace schoolreturn=. if edu21c_1==. & edu21c_2==. & edu21c_3==. & edu21c_4==. & edu21c_5==. & edu21d_1==. & edu21d_2==. & edu21d_3==. & edu21d_4==. & edu21d_5==.

	replace incomeloss=0 if inc9_hoh==1 | inc9_hoh==2		//Household income in the past 7 days compared to typical week in February 2020
	replace incomeloss=1 if inc9_hoh==0 | inc9_hoh==3
	
	gen govtsupport=1
	replace govtsupport=0 if net3=="0"
	
	gen cashtransfer=.
	gen cashtransfer_delay=.
}


*Regional attribution
gen regid=""
replace regid="CIV.1_1" if region==1
replace regid="CIV.13_1" if region==2
replace regid="CIV.2_1" if region==3
replace regid="CIV.3_1" if region==4
replace regid="CIV.4_1" if region==5
replace regid="CIV.5_1" if region==6
replace regid="CIV.6_1" if region==7
replace regid="CIV.7_1" if region==8
replace regid="CIV.8_1" if region==9
replace regid="CIV.9_1" if region==10
replace regid="CIV.10_1" if region==11
replace regid="CIV.11_1" if region==12
replace regid="CIV.12_1" if region==13
replace regid="CIV.14_1" if region==14

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* schoolreturn teacher cashtransfer* govtsupport incomeloss round month year
save "prep\CIV_ipa_r`r'.dta", replace
}
