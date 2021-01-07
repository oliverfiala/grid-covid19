*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"


*--- ROUNDS 1-3 ---
forvalues r=1/3 {
use "source\wb\UGA\round`r'\SEC10.dta", clear	//Safety nets
duplicates list HHID
duplicates drop HHID, force
merge 1:1 HHID using "source\wb\UGA\round`r'\SEC4.dta", nogen		//Access
merge 1:1 HHID using "source\wb\UGA\round`r'\Cover.dta", nogen
if `r'==1 {
merge 1:1 HHID using "source\wb\UGA\round`r'\SEC7.dta", nogen		//Food insecurity
}
else {
	merge 1:1 HHID using "source\wb\UGA\round`r'\SEC8.dta", nogen		//Food insecurity
}

*Weights
rename wfinal weight

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

*Health
gen medicine=.
replace medicine=0 if s4q08==1		//Past week (R1-3)
replace medicine=1 if s4q08==2
gen medicaltreatment=.
replace medicaltreatment=1 if s4q10==1	//Since August (R3)
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
if `r'==1 {
	replace teacher=1 if s4q16==1
	replace teacher=0 if s4q16==2
	replace remotelearning=1 if  s4q014==1
	replace remotelearning=0 if  s4q014==2
}

*Social protection (round 2 timeframe: since last interview)
gen cashtransfer_delay=.
if `r'==1 {
	gen govtsupport=.
	replace govtsupport=1 if s10q01==1		//Since 20 March (R1)
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
if `r'!=1 {
	replace cashtransfer_delay=1 if s10q05==1	//Refers to difficulties accessing any kind of assistance, not only cash transfer
	replace cashtransfer_delay=0 if s10q05==2
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

*Save
keep sex location region regid weight wealth poverty medicine medicaltreatment fsec teacher remotelearning govtsupport cashtransfer_delay
save "prep\UGA_wb_r`r'.dta", replace
}
