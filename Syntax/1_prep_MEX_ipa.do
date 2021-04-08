*Set working directory
cd "T:\PAC\Research\COVID-19\"

*Open survey
use "source\ipa\MEX_RECOVR_round1.dta", clear

*Disaggregation
rename dem1 age
drop gender		
gen sex=1		//Male 1 female 2
replace sex=2 if dem2==1
rename dem10a primary
rename dem10b secondary
gen schoolchildren=0
replace schoolchildren=1 if primary>0 | secondary>0
replace schoolchildren=. if primary==88 | primary==777 | secondary==777 | secondary==88
rename dem11 education
rename region reg
encode reg, gen(region)
gen location=.

*Wealth disaggregation: create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)

gen round=1
gen month=7
gen year=2020

*Variables
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

rename net1 cashtransfer_usual

gen schoolreturn_primary=.
replace schoolreturn_primary=1 if edu10_p_2==1 | edu10_p_3==1
replace schoolreturn_primary=0 if edu10_p_4==1 | edu10_p_5==1

gen schoolreturn_secondary=.
replace schoolreturn_secondary=1 if edu10_s_2==1 | edu10_s_3==1
replace schoolreturn_secondary=0 if edu10_s_4==1 | edu10_s_5==1

gen schoolreturn=schoolreturn_secondary

gen cashtransfer_delay=.		//delay or other difficulties
replace cashtransfer_delay=0 if net2==0
replace cashtransfer_delay=1 if net2==1 | net2==2 | net2==3 | net2==4 | net2==5 | net2==666

gen govtsupport=1
replace govtsupport=0 if net3=="0"
replace govtsupport=. if net3=="999"

gen incomeloss=.	//Over the past 7 days, compared to before the government closed the schools
replace incomeloss=1 if inc9==3
replace incomeloss=0 if inc9==1 | inc9==2

*Regional attribution: N/A as Mexico only distinguishes between Mexico City and Mexico State
gen regid=""

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* schoolreturn cashtransfer* govtsupport incomeloss round month year
save "prep\MEX_ipa_r1.dta", replace
