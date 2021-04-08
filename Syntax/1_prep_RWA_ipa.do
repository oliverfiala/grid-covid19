*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUNDS 1-2 ---
*Removing duplicated from R1
use "source\ipa\RWA_RECOVR_round1.dta", clear
duplicates drop participant_id, force
tempfile RWA_r1
save `RWA_r1', replace

forvalues r=1/2 {

*Open survey
if `r'==1 {
	use "source\ipa\RWA_RECOVR_round1.dta", clear
}
if `r'==2 {
	use "source\ipa\RWA_RECOVR_R2.dta", clear
	merge 1:1 participant_id using `RWA_r1', nogen keepusing(dem1 dem2 dem3 Code_UR PPI) keep(match master)
}

*Disaggregation
rename dem1 age
rename dem2 sex		//Male 1 female 2
encode dem3, gen(region)
rename Code_UR location
*replace region="" if region=="."
if `r'==1 {
	gen schoolchildren=0
	replace schoolchildren=1 if dem10>0
	rename dem11 education
	rename hlth2 babies
	gen disability=.
}
if `r'==2 {
	encode dem3f, gen(dem3g)
	replace region=dem3g if dem6f==1
	replace dem3=dem3f if dem6f==1
	rename edu14 disability		//A child living in the household has a disability
}

*Wealth disaggregation: create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)

gen round=1
if `r'==1 {
	gen month=7
}
if `r'==2 {
	gen month=10
}
gen year=2020

*Variables
if `r'==1 {
	rename hlth4 healthseeking

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

	replace net1=. if net1==-999
	rename net1 cashtransfer

	gen cashtransfer_delay=.
	replace cashtransfer_delay=. if net2=="-888" | net2=="-666" | net2=="."
	replace cashtransfer_delay=0 if net2_0==1
	replace cashtransfer_delay=1 if net2_0==0

	gen govtsupport=1
	replace govtsupport=0 if net3_0==1

	gen incomeloss=.	//Over the past 7 days, compared to a typical week before lockdown
	replace incomeloss=1 if inc9==3 | inc9==4
	replace incomeloss=0 if inc9==1 | inc9==2
}
if `r'==2 {
	gen healthseeking=. //Children in the household skip, delay, or unable to access health care services since June; 1 Disruption 0 No disruption
	replace healthseeking=1 if hlth4b==1 | hlth4c==1
	replace healthseeking=0 if hlth4b==0 & hlth4c==0
	
	gen fsec=.		//Children in the household, past 7 days
	replace fsec=1 if fsec1b>0 | fsec2b>0
	replace fsec=0 if fsec1b==0 & fsec2b==0
	
	gen remotelearning=.		//0 one or more child in the HH spent no time on remote learning during school closures; 1 all children in the HH spent at least some time a day doing distance learning during school closures
	replace remotelearning=1 if edu4_loop_1!=0 & edu4_loop_2!=0 & edu4_loop_3!=0 & edu4_loop_4!=0 & edu4_loop_5!=0 & edu4_loop_6!=0 & edu4_loop_7!=0 & edu4_loop_8!=0
	replace remotelearning=0 if edu4_loop_1==0 | edu4_loop_2==0 | edu4_loop_3==0 | edu4_loop_4==0 | edu4_loop_5==0 | edu4_loop_6==0 | edu4_loop_7==0 | edu4_loop_8==0
	replace remotelearning=. if edu4_loop_1==. & edu4_loop_2==. & edu4_loop_3==. & edu4_loop_4==. & edu4_loop_5==. & edu4_loop_6==. & edu4_loop_7==. & edu4_loop_8==.

	gen incomeloss=0		//Total household income this month compared to same time last year
	replace incomeloss=1 if inc15>4
	replace incomeloss=. if inc15<2
	
	gen govtsupport=.		//Last month that did not usually receive before March
	replace govtsupport=0 if net3==1
	replace govtsupport=1 if net3==2
	
	gen cashtransfer=.
	}

*Regional attribution: N/A due to missing province labels
gen regid=""
replace regid="RWA.3_1" if region==2
replace regid="RWA.5_1" if region==3
replace regid="RWA.1_1" if region==4
replace regid="RWA.2_1" if region==5
replace regid="RWA.4_1" if region==6

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location disability region regid wealth healthseeking fsec remotelearning* cashtransfer* govtsupport incomeloss round month year
save "prep\RWA_ipa_r`r'.dta", replace
}
