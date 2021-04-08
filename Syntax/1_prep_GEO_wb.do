*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUND 1 ---

*Open survey
use "source\wb\GEO\external_file_crrc_ghfs_wave1.dta", clear
gen round=1
gen month=12
gen year=2020

*Weights
rename hhwt weight

*Prepare dataset by renaming & creating variables of interest
*region is already there
*age is already there
*sex is already there		//1 Male 2 female
gen location=1		//1 Urban 2 rural
replace location=2 if settlement==3

*Wealth disaggregation
pca q14*
predict pc1 /*pc2 pc3*/, score 
xtile wealth=pc1[aw=weight], n(5)

*Health
*N/A

*Nutrition		//Timeframe: past month
gen fsec=1
replace fsec=0 if q31==5
replace fsec=. if q31==-1 | q31==-2

*Education
gen remotelearning=1		//Child engaged in any learning activity, not only remotely
replace remotelearning=. if q18_1==-7 & q18_2==-7 & q18_3==-7 & q18_4==-7
replace remotelearning=0 if q18_1==0 | q18_2==0 | q18_3==0 | q18_4==0

*Social protection
gen incomechange=q30-q29
gen incomeloss=0
replace incomeloss=1 if incomechange<0
replace incomeloss=. if q29==-1 | q29==-2 | q29==-9

gen govtsupport=.		//Any kind of assistance, not only from the govt, since March 2020
replace govtsupport=1 if q34==1
replace govtsupport=0 if q34==0

*Regional attribution
*label define region 1 "Adjara" 2 "Guria" 3 "Samegrelo-Zemo Svaneti" 4 "Imereti" 5 "Racha-Lechkhumi" 6 "Shida Kartli" 7 "Samtskhe-Javakheti" 8 "Kvemo Kartli" 9 "Mtskheta-Mtianeti" 10 "Kakheti" 11 "Tbilisi"

gen regid=""
replace regid="GE.AJ" if region==1
replace regid="GE.GU" if region==2
replace regid="GE.SZ" if region==3
replace regid="GE.IM.RK" if region==4 | region==5
replace regid="GE.SD" if region==6
replace regid="GE.SJ" if region==7
replace regid="GE.KK" if region==8
replace regid="GE.MM" if region==9
replace regid="GE.KA" if region==10
replace regid="GE.TB" if region==11

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth fsec remotelearning govtsupport incomeloss weight round month year
save "prep\GEO_wb_r1.dta", replace
