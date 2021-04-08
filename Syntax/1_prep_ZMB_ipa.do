*Set working directory
cd "T:\PAC\Research\COVID-19\"

*--- ROUNDS 1-2 ---
forvalues r=1/2 {

*Open survey
if `r'==1 {
	use "source\ipa\ZMB_RECOVR_round1.dta", clear
}
if `r'==2 {
	use "source\ipa\ZMB_RECOVR_R2.dta", clear
	ren dem3 dem3f
	merge m:1 caseid using "source\ipa\ZMB_RECOVR_round1.dta", nogen keepusing(dem1 dem2 dem3 PPI) keep(match master)
}

*Disaggregation

gen location=.
encode dem3, gen(region)
rename dem1 age
if `r'==1 {
	rename dem2 sex		//Male 1 female 2
	rename dem6 relocation
	gen schoolchildren=0
	replace schoolchildren=1 if dem10>0
	replace schoolchildren=. if dem10==.
	rename dem11 education
	rename hlth2 babies
}
if `r'==2 {
	rename dem2r sex 	//Male 1 female 2
}

gen round=1
gen year=2020
if `r'==1 {
	gen month=7
}
if `r'==2 {
	gen month=12
}

*Wealth disaggregation: create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)

*Variables
if `r'==1 {
	rename hlth4 healthseeking
	replace healthseeking=. if healthseeking==-888 | healthseeking==-999

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

	gen remotelearning_primary=.
	replace remotelearning_primary=1 if edu2==1
	replace remotelearning_primary=0 if edu2==0 | edu2==2 | edu2==3

	gen remotelearning_secondary=.
	replace remotelearning_secondary=1 if edu3==1
	replace remotelearning_secondary=0 if edu3==0 | edu3==2 | edu3==3

	gen schoolreturn=.
	replace schoolreturn=1 if edu10==1
	replace schoolreturn=0 if edu10==2| edu10==3 | edu10==4
	replace edu10=. if edu10==-999 | edu10==-888

	gen cashtransfer=1
	replace cashtransfer=0 if net1==0		//There are two yes in net1: yes to a specific program and yes to another program, coded as 1 and 2 respectively

	gen cashtransfer_delay=.		//delay or other difficulties
	replace cashtransfer_delay=. if net2=="-888"
	replace cashtransfer_delay=1 if net2_0==0
	replace cashtransfer_delay=0 if net2_0==1

	gen govtsupport=1
	replace govtsupport=0 if net3_0==1
	replace govtsupport=. if net3=="-666"

	gen incomeloss=.	//Over the past 7 days, compared to before the government closed the schools
	replace incomeloss=1 if inc9==3 | inc9==4
	replace incomeloss=0 if inc9==1 | inc9==2
}
if `r'==2 {
	gen healthseeking=.
	replace healthseeking=1 if hlth4b==1 | hlth4c==1	//1 Disruption 0 No disruption; timeframe (since June); agegroup: children
	replace healthseeking=0 if hlth4b==0 & hlth4c==0
	
	gen fsec=. 		//Too few responses
	
	gen remotelearning=.		//Children in the household spent at least some time a day on education in the past week since schools closed
	replace remotelearning=0 if edu4==0
	replace remotelearning=1 if edu4>0
	
	gen schoolreturn=.		//All children in the household have resumed schooling
	replace schoolreturn=1 if (edu21c_1==1 | edu21c_1==.) & (edu21c_2==1 | edu21c_2==.) & (edu21c_3==1 | edu21c_3==.) & (edu21c_4==1 | edu21c_4==.) & (edu21d_1==1 | edu21d_1==.) & (edu21d_2==1 | edu21d_2==.) & (edu21d_3==1 | edu21d_3==.)
	replace schoolreturn=0 if edu21c_1==0 | edu21c_2==0 | edu21c_3==0 | edu21c_4==0 | edu21d_1==0 | edu21d_2==0 | edu21d_3==0
	
	gen incomeloss=.		//Total HH income compared to same time last year
	replace incomeloss=1 if inc15>3
	replace incomeloss=0 if inc15==1 | inc15==2 | inc15==3
	
	gen govtsupport=.		//Any support in last month that do not usually receive
	replace govtsupport=1 if net3==1 | net3==2 | net3==-666
	replace govtsupport=0 if net3==0
	
	gen cashtransfer=.
}

*Regional attribution
label define region 1 "Central" 2 "Copperbelt" 3 "Eastern" 4 "Luapula" 5 "Muchinga" /*
*/	6 "Northern" 7 "Northwestern" 8 "Southern" 9 "Western" 10 "Lusaka", modify
gen regid=""
replace regid="ZMB.1_1" if region==1
replace regid="ZMB.2_1" if region==2
replace regid="ZMB.3_1" if region==3
replace regid="ZMB.4_1" if region==4
replace regid="ZMB.6_1" if region==5
replace regid="ZMB.8_1" if region==6
replace regid="ZMB.7_1" if region==7
replace regid="ZMB.9_1" if region==8
replace regid="ZMB.10_1" if region==9
replace regid="ZMB.5_1" if region==10

if `r'==2 {
	replace regid="ZMB.1_1" if dem3f==1
	replace regid="ZMB.2_1" if dem3f==2
	replace regid="ZMB.3_1" if dem3f==3
	replace regid="ZMB.4_1" if dem3f==4
	replace regid="ZMB.6_1" if dem3f==5
	replace regid="ZMB.8_1" if dem3f==6
	replace regid="ZMB.7_1" if dem3f==7
	replace regid="ZMB.9_1" if dem3f==8
	replace regid="ZMB.10_1" if dem3f==9
	replace regid="ZMB.5_1" if dem3f==10
}

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* schoolreturn cashtransfer* govtsupport incomeloss round month year
save "prep\ZMB_ipa_r`r'.dta", replace
}
