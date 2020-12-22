*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*Open survey
use "source\ipa\SLE_RECOVR_round1.dta", clear

*Disaggregation
rename dem1 age
rename dem2 sex		//Male 1 female 2
ren dem4 region
rename dem6 relocation
gen schoolchildren=0
replace schoolchildren=1 if dem10>0
rename dem11 education
rename hlth2 babies
gen location=1
replace location=2 if rural==1

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
replace cashtransfer_delay=. if net2=="-888"
replace cashtransfer_delay=1 if net2=="1"
replace cashtransfer_delay=0 if net2=="0"

gen govtsupport=1
replace govtsupport=0 if net3_0==1

gen incomeloss=.	//Over the past 7 days, compared to before the government closed the schools/end of March 2020
replace incomeloss=1 if inc9==3 | inc9==4
replace incomeloss=0 if inc9==1 | inc9==2

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

*Save
keep sex location region regid wealth healthseeking fsec remotelearning* cashtransfer* govtsupport incomeloss
save "prep\SLE_ipa_r1.dta", replace
