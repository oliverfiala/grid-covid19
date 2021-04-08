*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUNDS 1-2 ---
forvalues r=1/2 {

*Open survey
if `r'==1 {
	use "source\ipa\SLE_RECOVR_round1.dta", clear
}
if `r'==2 {
	use "source\ipa\SLE_RECOVR_R2.dta", clear
	merge 1:1 id using "source\ipa\SLE_RECOVR_round1.dta", nogen keepusing(dem1 dem2 dem4 PPI rural) keep(match master)
}

*Disaggregation
rename dem1 age
rename dem2 sex		//Male 1 female 2
ren dem4 region
gen location=1
replace location=2 if rural==1
if `r'==1 {
	rename dem6 relocation
	gen schoolchildren=0
	replace schoolchildren=1 if dem10>0
	rename dem11 education
	rename hlth2 babies
}
if `r'==2 {
	replace region=dem4f if dem6f==1
}

*Wealth disaggregation: create quintiles based on Poverty Probability Index
gen _PPI=1-PPI
xtile wealth=_PPI, n(5)

gen round=1
if `r'==1 {
	gen month=7
}
if `r'==2 {
	gen month=10
}
gen year=2020

*Variables
gen govtsupport=1	//Past month vs usual (R1)/before March 2020(R2)
gen incomeloss=.	//Over the past 7 days, compared to before the government closed the schools/end of March 2020 (R1)/Household's total income vs same time last year (R2)
if `r'==1 {
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
	
	gen schoolreturn=.

	replace net1=. if net1==-999
	rename net1 cashtransfer

	gen cashtransfer_delay=.
	replace cashtransfer_delay=. if net2=="-888"
	replace cashtransfer_delay=1 if net2=="1"
	replace cashtransfer_delay=0 if net2=="0"

	replace govtsupport=0 if net3_0==1

	replace incomeloss=1 if inc9==3 | inc9==4
	replace incomeloss=0 if inc9==1 | inc9==2
}
if `r'==2 {
	gen healthseeking=. //Children in the household skip, delay, or unable to access health care services since June; 1 Disruption 0 No disruption
	replace healthseeking=1 if hlth4b==2 | hlth4c==3
	replace healthseeking=0 if hlth4b==1 & hlth4c==2
	
	gen fsec=.		//Children in the household, past 7 days
	replace fsec=1 if fsec1b>0 | fsec2b>0
	replace fsec=0 if fsec1b==0 & fsec2b==0
	
	gen schoolreturn=0		//All school children in the household have resumed or will resume schooling in October
	replace schoolreturn=1 if (edu21_child1==1 | edu21_child1==.) & (edu21_child2==1 | edu21_child2==.) & (edu21_child3==1 | edu21_child3==.) & (edu21_child4==1 | edu21_child4==.) & (edu21_child5==1 | edu21_child5==.) & (edu21_child6==1 | edu21_child6==.) & (edu21_child7==1 | edu21_child7==.) & (edu21_child8==1 | edu21_child8==.) & (edu21_child9==1 | edu21_child9==.) & (edu21_child10==1 | edu21_child10==.) & (edu21_child11==1 | edu21_child11==.) & (edu21_child12==1 | edu21_child12==.) & (edu21_child13==1 | edu21_child13==.)
	replace schoolreturn=. if edu21_child1==. & edu21_child2==. & edu21_child3==. & edu21_child4==. & edu21_child5==. & edu21_child6==. & edu21_child7==. & edu21_child8==. & edu21_child9==. & edu21_child10==. & edu21_child11==. & edu21_child12==. & edu21_child13==.
	
	gen remotelearning_primary=.
	gen remotelearning_secondary=.
	/* Which of the following tools are children using to help continue their education? 100% unlikely

	replace remotelearning_primary=0 if edu16a1==0 & edu16a2==0 & edu16a3==0 & edu16a4==0 & edu16a5==0 & edu16a6==0 & edu16a7==0
	replace remotelearning_primary=1 if edu16a1==1 | edu16a2==1 | edu16a3==1 | edu16a4==1 | edu16a5==1 | edu16a6==1 | edu16a7==1
	
	replace remotelearning_secondary=0 if edu16b1==0 & edu16b2==0 & edu16b3==0 & edu16b4==0 & edu16b5==0 & edu16b6==0 & edu16b7==0
	replace remotelearning_secondary=1 if edu16b1==1 | edu16b2==1 | edu16b3==1 | edu16b4==1 | edu16b5==1 | edu16b6==1 | edu16b7==1
	*/	
	replace incomeloss=1 if inc15>5
	replace incomeloss=0 if inc15==3 | inc15==4 | inc15==5
	
	replace govtsupport=0 if net3=="0"
	
	gen cashtransfer=.
	gen cashtransfer_delay=.
}

*Regional attribution: create larger regions for sample sizes and connection with shapefile
ren region region2
label define region2 1 "Bombali" 2 "Falaba" 3 "Karena" 4 "Portloko" 5 "Kambia" 6 "Tonkolili" 7 "Koinadugu" 8 "Bo" /*
*/	9 "Bonthe" 10 "Moyamba" 11 "Pujehun" 12 "Kailahun" 13 "Kenema" 14 "Kono" 15 "Western Rural" 16 "Western Urban"
label values region2 region2 
gen region=1 if region2==12 | region2==13 | region2==14
replace region=2 if region2==1 | region2==2 | region2==3 | region2==4 | region2==5 | region2==6 | region2==4
replace region=3 if region2==8 | region2==9 | region2==10 | region2==11
replace region=4 if region2==15 | region2==16
label define region 1 "East" 2 "North" 3 "South" 4 "West"
label values region region
gen regid=""
replace regid="SLE.1_1" if region==1
replace regid="SLE.2_1" if region==2
replace regid="SLE.3_1" if region==3
replace regid="SLE.4_1" if region==4

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* cashtransfer* schoolreturn govtsupport incomeloss round month year
save "prep\SLE_ipa_r`r'.dta", replace
}
