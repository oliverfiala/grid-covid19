*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*Open survey
use "source\ipa\RWA_RECOVR_round1.dta", clear

*Disaggregation
rename dem1 age
rename dem2 sex		//Male 1 female 2
encode dem3, gen(region)
*replace region="" if region=="."
gen schoolchildren=0
replace schoolchildren=1 if dem10>0
rename dem11 education
rename hlth2 babies
rename Code_UR location

*Wealth disaggregation: create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)

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

*Regional attribution: N/A due to missing province labels
gen regid=""
replace regid="RWA.3_1" if region==2
replace regid="RWA.5_1" if region==3
replace regid="RWA.1_1" if region==4
replace regid="RWA.2_1" if region==5
replace regid="RWA.4_1" if region==6

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* cashtransfer* govtsupport incomeloss
save "prep\RWA_ipa_r1.dta", replace
