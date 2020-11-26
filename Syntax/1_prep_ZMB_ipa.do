*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*Open survey
use "source\ipa\ZMB_RECOVR_round1.dta", clear

*Disaggregation
rename dem1 age
rename dem2 sex		//Male 1 female 2
encode dem3, gen(region)
rename dem6 relocation
gen schoolchildren=0
replace schoolchildren=1 if dem10>0
replace schoolchildren=. if dem10==.
rename dem11 education
rename hlth2 babies
gen location=.

*Wealth disaggregation: create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)

*Variables
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

*Regional attribution
label define region 1 "Central" 2 "Copperbelt" 3 "Eastern" 4 "Luapula" 5 "Muchinga" /*
*/	6 "Northern" 7 "Northwestern" 8 "Southern" 9 "Western" 10 "Lusaka", modify
gen regid=""
replace regid="ZMDHS2018456001" if region==1
replace regid="ZMDHS2018456002" if region==2
replace regid="ZMDHS2018456012" if region==3
replace regid="ZMDHS2018456004" if region==4
replace regid="ZMDHS2018456011" if region==5
replace regid="ZMDHS2018456010" if region==6
replace regid="ZMDHS2018456007" if region==7
replace regid="ZMDHS2018456008" if region==8
replace regid="ZMDHS2018456009" if region==9
replace regid="ZMDHS2018456005" if region==10

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* schoolreturn cashtransfer* govtsupport
save "prep\ZMB_ipa_r1.dta", replace
