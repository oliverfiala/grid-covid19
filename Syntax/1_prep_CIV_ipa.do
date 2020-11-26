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

*Regional attribution
gen regid=""
replace regid="CI.AB" if region==1
replace regid="CI.YM" if region==2
replace regid="CI.BA" if region==3
replace regid="CI.CM" if region==4
replace regid="CI.DE" if region==5
replace regid="CI.GD" if region==6
replace regid="CI.LA" if region==7
replace regid="CI.LN" if region==8
replace regid="CI.MN" if region==9
replace regid="CI.SM" if region==10
replace regid="CI.SV" if region==11
replace regid="CI.VB" if region==12
replace regid="CI.WB" if region==13
replace regid="CI.ZA" if region==14

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* schoolreturn cashtransfer* govtsupport
save "prep\CIV_ipa_r1.dta", replace
