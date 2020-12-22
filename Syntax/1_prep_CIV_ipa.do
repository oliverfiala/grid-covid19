*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*Open survey
use "source\ipa\CDI_RECOVR_round1.dta", clear

*Disaggregation
rename dem1 age
drop gender
rename dem2 sex		//Male 1 female 2
rename dem3 region
rename dem10a primary
rename dem10b secondary
gen schoolchildren=0
replace schoolchildren=1 if primary>0 | secondary>0
rename dem11 education
gen location=.

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

rename edu2 remotelearning_primary
rename edu3 remotelearning_secondary
rename edu10b schoolreturn

rename net1 cashtransfer
rename net2 cashtransfer_delay		// delay or difficulty
rename net3 govtsupport

gen incomeloss=.	//Over the past 7 days, compared to before the government closed the schools
replace incomeloss=1 if inc9==3
replace incomeloss=0 if inc9==1 | inc9==2

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

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* schoolreturn cashtransfer* govtsupport incomeloss
save "prep\CIV_ipa_r1.dta", replace
