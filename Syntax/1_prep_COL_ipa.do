*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*Open survey
use "source\ipa\COL_RECOVR_round1.dta", clear

*Disaggregation
rename dem1 age	
gen sex=1		//Male 1 female 2
replace sex=2 if dem2==1
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

*Variables
gen healthseeking=hlth4
replace healthseeking=0 if hlth4==2

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
replace remotelearning_primary=1 if edu2a-edu2b==0
replace remotelearning_primary=0 if edu2a-edu2b>0
replace remotelearning_primary=. if (edu2a==. | edu2a==0)

gen remotelearning_secondary=.
replace remotelearning_secondary=1 if edu3a-edu3b==0
replace remotelearning_secondary=0 if edu3a-edu3b>0
replace remotelearning_secondary=. if (edu3a==. | edu3a==0)

gen cashtransfer=.
replace cashtransfer=0 if net1==2
replace cashtransfer=1 if net1==1

gen cashtransfer_delay=.
replace cashtransfer_delay=0 if net2==2
replace cashtransfer_delay=1 if net2==1

gen govtsupport=.
replace govtsupport=0 if net3==2
replace govtsupport=1 if net3==1

gen incomeloss=.	//Over the past 7 days, compared to before the government closed the schools
replace incomeloss=1 if inc9==3 | inc9==4
replace incomeloss=0 if inc9==1 | inc9==2

*Regional attribution
gen regid=""
replace regid="CODHS2015397037" if region==5
replace regid="CODHS2015397026" if region==8
replace regid="CODHS2015397036" if region==11
replace regid="CODHS2015397028" if region==13
replace regid="CODHS2015397033" if region==15
replace regid="CODHS2015397038" if region==17
replace regid="CODHS2015397043" if region==18
replace regid="CODHS2015397045" if region==19
replace regid="CODHS2015397024" if region==20
replace regid="CODHS2015397030" if region==23
replace regid="CODHS2015397034" if region==25
replace regid="CODHS2015397047" if region==27
replace regid="CODHS2015397042" if region==41
replace regid="CODHS2015397023" if region==44
replace regid="CODHS2015397025" if region==47
replace regid="CODHS2015397035" if region==50
replace regid="CODHS2015397046" if region==52
replace regid="CODHS2015397031" if region==54
replace regid="CODHS2015397040" if region==63
replace regid="CODHS2015397039" if region==66
replace regid="CODHS2015397032" if region==68
replace regid="CODHS2015397029" if region==70
replace regid="CODHS2015397041" if region==73
replace regid="CODHS2015397044" if region==76
replace regid="CODHS2015397048" if region==81
replace regid="CODHS2015397049" if region==85
replace regid="CODHS2015397053" if region==86
replace regid="CODHS2015397027" if region==88
replace regid="CODHS2015397052" if region==91
replace regid="CODHS2015397050" if region==94
replace regid="CODHS2015397054" if region==95
replace regid="CODHS2015397055" if region==97
replace regid="CODHS2015397051" if region==99

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* cashtransfer* govtsupport incomeloss
save "prep\COL_ipa_r1.dta", replace
