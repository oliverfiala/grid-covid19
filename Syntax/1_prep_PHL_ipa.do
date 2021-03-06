*Set working directory
cd "T:\PAC\Research\COVID-19\"


*Open survey
use "source\ipa\PHP_RECOVR_round1.dta", clear

*Disaggregation
rename dem1 age
gen sex=1		//Male 1 female 2
replace sex=2 if dem2==1
rename dem3 region
rename dem10a schoolchildren //grade 12 in the national school system
rename dem13 education
rename hlth2 babies
gen disability=1
replace disability=2 if hlth2a>0
rename region region1
encode region1, gen(region)
gen location=2	//1 Urban 2 Rural
replace location=1 if region==4 | region==7 | region==15

*Wealth disaggregation: create quintiles based on Poverty Probability Index
xtile _wealth=PPI, n(5)		// due to distribution PPIs in PHL, negative PPI lead only to 4 groups when using xtile; instead calculate groups based on original PPI and reverse
gen wealth=1 if _wealth==5
replace wealth=2 if _wealth==4
replace wealth=4 if _wealth==2
replace wealth=5 if _wealth==1

gen round=1
gen month=7
gen year=2020

*Variables
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

gen schoolreturn=.
replace schoolreturn=1 if edu10a==1 | edu10a==2
replace schoolreturn=0 if edu10a==3 | edu10a==4 | edu10a==5

rename net1 cashtransfer
rename net2 cashtransfer_delay
rename net1_p govtsupport

gen incomeloss=.	//Over the past 7 days, compared to before COVID-19 started affecting the country (excl. remittances)
replace incomeloss=1 if inc9==3 | inc9==4
replace incomeloss=0 if inc9==1 | inc9==2

*Regional attribution
gen regid=""
replace regid="PHDHS2017439019" if region==1
replace regid="PHDHS2017439003" if region==2
replace regid="PHDHS2017439008" if region==3
replace regid="PHDHS2017439002" if region==4
replace regid="PHDHS2017439004" if region==5
replace regid="PHDHS2017439005" if region==6
replace regid="PHDHS2017439006" if region==7
replace regid="PHDHS2017439007" if region==8
replace regid="PHDHS2017439015" if region==9
replace regid="PHDHS2017439009" if region==10
replace regid="PHDHS2017439011" if region==11
replace regid="PHDHS2017439012" if region==12
replace regid="PHDHS2017439013" if region==13
replace regid="PHDHS2017439016" if region==14
replace regid="PHDHS2017439017" if region==15
replace regid="PHDHS2017439018" if region==16
replace regid="PHDHS2017439020" if region==17

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth fsec schoolreturn cashtransfer* govtsupport incomeloss round month year
save "prep\PHL_ipa_r1.dta", replace
