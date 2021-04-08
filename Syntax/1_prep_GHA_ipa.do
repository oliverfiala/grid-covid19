*Set working directory
cd "T:\PAC\Research\COVID-19\"


*Open survey
use "source\ipa\GHN_RECOVR_round1.dta", clear

*Disaggregation
rename dem1 age
rename dem2 sex		//Male 1 female 2
rename dem3 region
rename dem6 relocation
gen schoolchildren=0
destring dem10, replace
replace schoolchildren=1 if dem10>0
rename dem11 education
rename hlth2 babies
gen location=.

*Wealth disaggregation: create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)

gen round=1
gen month=5
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

*New variables
gen cashtransfer=.
replace cashtransfer=1 if net1==1
replace cashtransfer=0 if net1==0

gen cashtransfer_delay=.		//delay or other difficulties
replace cashtransfer_delay=1 if net2_0==0
replace cashtransfer_delay=0 if net2_0==1

gen govtsupport=1
replace govtsupport=0 if net3_0==1
replace govtsupport=. if net3__99==1 | net3__88==1

gen incomeloss=.	//Over the past 7 days, compared to before the government closed the schools/mid-March 2020
replace incomeloss=1 if inc9==3 | inc9==4
replace incomeloss=0 if inc9==1 | inc9==2

*Regional attribution: N/A due to missing province labels
gen regid=""
replace regid="GH.AHA" if region==1
replace regid="GH.ASH" if region==2
replace regid="GH.BON" if region==3
replace regid="GH.BOE" if region==4
replace regid="GH.CEN" if region==5
replace regid="GH.EAS" if region==6
replace regid="GH.ACC" if region==7
replace regid="GH.NOE" if region==8
replace regid="GH.NOR" if region==9
replace regid="GH.OTI" if region==10
replace regid="GH.SAV" if region==11
replace regid="GH.UPE" if region==12
replace regid="GH.UPW" if region==13
replace regid="GH.VOL" if region==14
replace regid="GH.WES" if region==15
replace regid="GH.WEN" if region==16

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* cashtransfer* govtsupport incomeloss round month year
save "prep\GHA_ipa_r1.dta", replace
