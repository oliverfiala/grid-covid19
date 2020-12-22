*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*Open survey
use "source\ipa\BFA_RECOVR_round1.dta", clear

*Disaggregation
rename dem1 age
rename dem2 sex		//Male 1 female 2
rename dem3 region
rename dem6 relocation
rename dem10a primary
rename dem10b secondary
gen schoolchildren=0
destring primary, replace
destring secondary, replace
replace schoolchildren=1 if primary>=1 | secondary>=1
rename dem11 education
rename hlth2 babies

gen location=1
replace location=2 if area=="Rural"

*Wealth disaggregation: create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)

*Variables
rename hlth4 healthseeking
rename fsec1 mealsize
rename fsec2 mealnumber

destring mealsize, replace
destring mealnumber, replace

replace mealsize=. if mealsize==-888 | mealsize==-999
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
replace remotelearning_primary=0 if edu2!=1 & edu2!=.

gen remotelearning_secondary=.
replace remotelearning_secondary=1 if edu3==1
replace remotelearning_secondary=0 if edu3!=1 & edu3!=.

rename net1 cashtransfer

gen cashtransfer_delay=.		//delay or other difficulties
replace cashtransfer_delay=1 if net2_0==0
replace cashtransfer_delay=0 if net2_0==1

gen incomeloss=.	//Over the past 7 days, compared to before the pandemic started/February 2020
replace incomeloss=1 if inc9==0 | inc9==3
replace incomeloss=0 if inc9==1 | inc9==2

gen schoolreturn=.
replace schoolreturn=1 if edu10==1
replace schoolreturn=0 if edu10==2 | edu10==3 | edu10==4
label define schoolreturn 1 "Return" 0 "Dropout"
label values schoolreturn schoolreturn

gen govtsupport=1
replace govtsupport=0 if net3=="0"

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


*Save
keep sex location region regid wealth healthseeking fsec remotelearning* schoolreturn cashtransfer* govtsupport incomeloss
save "prep\BFA_ipa_r1.dta", replace
