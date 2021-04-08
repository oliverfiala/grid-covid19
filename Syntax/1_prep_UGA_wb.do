*Set working directory
cd "T:\PAC\Research\COVID-19\"

*--- ROUNDS 1-4 ---
forvalues r=1/4 {

*Prepare incomeloss file
use "source\wb\UGA\round`r'\SEC6.dta", clear	//Income loss
duplicates list HHID
duplicates drop HHID, force
tempfile r`r'_incomeloss
save `r`r'_incomeloss', replace

*Open surveys
use "source\wb\UGA\round`r'\SEC10.dta", clear	//Safety nets
duplicates list HHID
duplicates drop HHID, force
merge 1:1 HHID using "source\wb\UGA\round`r'\SEC4.dta", nogen		//Access
merge 1:1 HHID using "source\wb\UGA\round`r'\Cover.dta", nogen
merge 1:1 HHID using `r`r'_incomeloss', nogen		//Income loss
if `r'==1 {
	merge 1:1 HHID using "source\wb\UGA\round`r'\SEC7.dta", nogen		//Food insecurity
}
if `r'!=1 {
	merge 1:1 HHID using "source\wb\UGA\round`r'\SEC8.dta", nogen		//Food insecurity
}
if `r'==4 {
	merge 1:m HHID using "source\wb\UGA\round`r'\SEC1C.dta", nogen		//Education
}

*Weights
rename wfinal weight

gen round=`r'
gen month=.
gen year=2020
if `r'==1 {
	replace month=6
}
if `r'==2 {
	replace month=8
}
if `r'==3 {
	replace month=10
}
if `r'==4 {
	replace month=11
}

*Prepare dataset by renaming & creating variables on interest
gen location=1
replace location=2 if urban==3
gen sex=.
rename region area
encode subreg, gen(region)

*Wealth disaggregation
if `r'==2 {
	forvalues x=1/5 {
	replace s4q12__`x'=0 if s4q12__`x'==2
	}

	pca s4q12__1 s4q12__2 s4q12__3 s4q12__4 s4q12__5
	*screeplot, yline(1) ci(het)
	predict pc1 /*pc2 pc3*/, score 
	xtile wealth=pc1[aw=weight], n(5)
}
else {
	gen wealth=.
	}
gen poverty=.

*Health		//
gen medicine=.
replace medicine=0 if s4q08==1		//Past week (R1-4)	NB. Unable!
replace medicine=1 if s4q08==2
gen medicaltreatment=.
replace medicaltreatment=1 if s4q10==1	//Since August (R3); since September (R4)
replace medicaltreatment=0 if s4q10==2

*Nutrition (FIES scale - 30 days - http://www.fao.org/3/a-as583e.pdf)
gen fies=1		//Mild
if `r'==1 {
	replace fies=0 if s7q01+s7q02+s7q03+s7q04+s7q05+s7q06+s7q07+s7q08==16	//None
	replace fies=2 if (s7q04==1 | s7q05==1 | s7q06==1) //Moderate
	replace fies=3 if (s7q07==1 | s7q08==1) //Severe
	}
else {
	replace fies=0 if s8q01+s8q02+s8q03+s8q04+s8q05+s8q06+s8q07+s8q08==16	//None
	replace fies=2 if (s8q04==1 | s8q05==1 | s8q06==1) //Moderate
	replace fies=3 if (s8q07==1 | s8q08==1) //Severe
}
gen fsec=0
replace fsec=1 if fies==2 | fies==3

*Education
gen teacher=.
gen remotelearning=.
gen schoolreturn=.
if `r'==1 {
	replace teacher=1 if s4q16==1		//Timeframe: past week
	replace teacher=0 if s4q16==2
	replace remotelearning=1 if  s4q014==1		//Timeframe: since schools closed
	replace remotelearning=0 if  s4q014==2
}
if 	`r'==4 {
	replace schoolreturn=1 if s1cq03==1		//Whether a child is currently going to school
	replace schoolreturn=0 if s1cq03==2
	replace remotelearning=1 if s1cq09==1		//Timeframe: past 7 days
	replace remotelearning=0 if s1cq09==2
}

*Social protection (round 2 timeframe: since last interview)
gen cashtransfer_delay=.
if `r'==1 | `r'==4 {
	gen govtsupport=.
	replace govtsupport=1 if s10q01==1		//Since 20 March (R1)/last interview (R2-4); R4 refers to assistance from any institution, not only govt
	replace govtsupport=0 if s10q01==2
	}
else {
	gen assistance=1
	replace assistance=0 if s10q01==2		//Since last interview
	gen govtsupport=0
	replace govtsupport=1 if s10q03__1==1
	gen ngosupport=0
	replace ngosupport=1 if s10q03__4==1
}
if `r'!=1 & `r'!=4 {
	replace cashtransfer_delay=1 if s10q05==1	//Refers to difficulties accessing any kind of assistance, not only cash transfer
	replace cashtransfer_delay=0 if s10q05==2
}

*Income loss
gen incomeloss=.		//Timeframe: since school closures (R1)/last call(R2-4)
gen incomelossyear=.
replace incomeloss=0 if s6q02==1 | s6q02==2
replace incomeloss=1 if s6q02==3 | s6q02==4
if `r'==4 {
	replace incomelossyear=1 if s6q03==3		//Average monhtly income during 12 months prior to school closures (March 19-20) compared to post-COVID
	replace incomelossyear=0 if s6q03==1 | s6q03==2
}

*Regional attribution
gen regid=""
replace regid="UGDHS2016452030" if region==1
replace regid="UGDHS2016452033" if region==2
replace regid="UGDHS2016452003" if region==3	// Buganda Nouth seems to be consistent with Central 2 in DHS shapefiles
replace regid="UGDHS2016452002" if region==4	// Buganda South seems to be consistent with Central 1 in DHS shapefiles
replace regid="UGDHS2016452026" if region==5
replace regid="UGDHS2016452031" if region==6
replace regid="UGDHS2016452025" if region==7
replace regid="UGDHS2016452027" if region==8	// Elgon seems to be Bugishu region
replace regid="UGDHS2016452004" if region==9
replace regid="UGDHS2016452012" if region==10
replace regid="UGDHS2016452034" if region==11
replace regid="UGDHS2016452029" if region==12
replace regid="UGDHS2016452028" if region==13
replace regid="UGDHS2016452032" if region==14
replace regid="UGDHS2016452009" if region==15

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid weight wealth poverty medicine medicaltreatment fsec teacher remotelearning schoolreturn govtsupport cashtransfer_delay incomeloss incomelossyear round month year
save "prep\UGA_wb_r`r'.dta", replace
}
