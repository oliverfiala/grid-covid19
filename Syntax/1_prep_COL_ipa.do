*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUNDS 1-3 ---
forvalues r=1/3 {

*Open survey
if `r'==1 {
	use "source\ipa\COL_RECOVR_round1.dta", clear
}
else {
	use "source\ipa\COL_RECOVR_R`r'.dta", clear
}

*Disaggregation
if `r'!=1 {
	merge 1:1 caseid using "source\ipa\COL_RECOVR_round1.dta", nogen keepusing(dem1 dem2 dem3 PPI) keep(match master)
}
rename dem3 region
if `r'!=1 {
	replace region=dem3f if dem6f==1
}
gen location=.
gen disability=.
rename dem1 age	
gen sex=1		//Male 1 female 2
replace sex=2 if dem2==1
if `r'!=1 {
	replace disability=dem22
	*replace location=dem19
	*replace location=2 if location==0
}
if `r'==1 {
	rename dem6 relocation
	gen schoolchildren=0
	destring dem10, replace
	replace schoolchildren=1 if dem10>0
	rename dem11 education
	rename hlth2 babies
}

*Wealth disaggregation
*Create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)		//1 Poorest 5 Richest

gen round=`r'
gen year=2020
if `r'==1 {
	gen month=5
}
if `r'==2 {
	gen month=8
}
if `r'==3 {
	gen month=11
}

*Variables
if `r'==1 {
	gen healthseeking=hlth4		//Timeframe: since March 24 (R1)/mid-May (R2)/beginning of September (R3)
	replace healthseeking=0 if hlth4==2
}
else {
	gen healthseeking=0
	replace healthseeking=1 if hlth4a==1 | hlth4b==1		//Anyone in the household delayed, skipped, or unable to complete health care visits 
}

if `r'==1 {		//Timeframe: past 7 days
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
}
else {
	gen fsec=.		//Children and teenagers in the household had to limit portion size or reduce the number of meals
	replace fsec=1 if fsec1b>0 | fsec2b>0
	replace fsec=0 if fsec1b==0 & fsec2b==0
}

gen remotelearning_primary=.
gen remotelearning_secondary=.
if `r'==1 {
	replace remotelearning_primary=1 if edu2a-edu2b==0
	replace remotelearning_primary=0 if edu2a-edu2b>0
	replace remotelearning_primary=. if (edu2a==. | edu2a==0)

	replace remotelearning_secondary=1 if edu3a-edu3b==0
	replace remotelearning_secondary=0 if edu3a-edu3b>0
	replace remotelearning_secondary=. if (edu3a==. | edu3a==0)
}

gen schoolreturn=.		//Timeframe: second semester 2020 (R2)/first semester 2021 (R3)
if `r'==2 {
	replace schoolreturn=1 if edu21_c==0 | edu21_c==1		//Primary school children's return to school if institutions re-open 
	replace schoolreturn=0 if edu21_c==2 | edu21_c==3
}
if `r'==3 {
	replace schoolreturn=1 if edu21_c==1 | edu21_c==2		//Primary school children's return to school if institutions re-open 
	replace schoolreturn=0 if edu21_c==4 | edu21_c==3
}

gen cashtransfer=.
gen cashtransfer_delay=.
if `r'==1 {
	replace cashtransfer=0 if net1==2
	replace cashtransfer=1 if net1==1
	replace cashtransfer_delay=0 if net2==2
	replace cashtransfer_delay=1 if net2==1
}

gen govtsupport=0		//Timeframe: past month (R1-2)/October 2020 (R3)
replace govtsupport=1 if net3==1

gen incomeloss=.
if `r'==1 {
	replace incomeloss=1 if inc9==3 | inc9==4	//Over the past 7 days, compared to before the government closed the schools
	replace incomeloss=0 if inc9==1 | inc9==2
}
else {
	replace incomeloss=1 if inc15<2		//Household's total income lower than before national quarantine
	replace incomeloss=0 if inc15<3
}

*Wellbeing: hlth10 adults' mental health; chd8 children's mental health

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

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep age sex location disability region regid wealth healthseeking fsec remotelearning* schoolreturn cashtransfer* govtsupport incomeloss round month year
save "prep\COL_ipa_r`r'.dta", replace
}
