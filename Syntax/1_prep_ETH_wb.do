*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"


*--- ROUNDS 1-6 ---

forvalues r=1/6 {
use "source\wb\ETH\r`r'_wb_lsms_hfpm_hh_survey_public_microdata.dta", clear
gen round=`r'

*Weights
if `r'==6 {
	gen weight=1
}
else {
	rename phw`r' weight
}

*Prepare dataset by renaming & creating variables on interest
rename cs1_region region
gen location=1
replace location=2 if cs4_sector==1	//Urban 1 rural 2
if `r'==1 {
	gen sex=.
	gen age=.
}
else {
	rename ii4_resp_gender sex	 		//Male 1 female 2
	rename ii4_resp_age age
}
gen wealth=.

*Health
rename ac7_med_access medicaltreatment
gen medicine=.
replace medicine=1 if ac1_atb_med==1
replace medicine=0 if ac1_atb_med==0

*Food security
*Nutrition (FIES scale - 30 days - http://www.fao.org/3/a-as583e.pdf)
gen fies=.
gen fsec=.

if `r'!=1 {
	replace fies=0 if fi1_enough==0 & fi2_healthy==0 & fi3_fewkinds==0 & fi4_skipmeal==0 & fi5_ateless==0 & fi6_noteatfullday==0 & fi7_outoffood==0 & fi8_hungrynoteat==0
	replace fies=1 if fi1_enough==1 | fi2_healthy==1 | fi3_fewkinds==1
	replace fies=2 if fi4_skipmeal==1 | fi5_ateless==1 | fi6_noteatfullday==1
	replace fies=3 if fi7_outoffood==1 | fi8_hungrynoteat==1
	replace fsec=0 if fies==0 | fies==1
	replace fsec=1 if fies==2 | fies==3
}

*Education
if `r'==1 | `r'==2 {
	rename ac4_2_edu remotelearning
	replace remotelearning=. if remotelearning==-99 | remotelearning==-98
}
if `r'==3 | `r'==4 | `r'==5 {
	rename ac4a_pri_child remotelearning_primary
	rename ac4b_sec_child remotelearning_secondary
	replace remotelearning_primary=. if remotelearning_primary==-99 | remotelearning_primary==-98
	replace remotelearning_secondary=. if remotelearning_secondary==-99 | remotelearning_secondary==-98
}
if `r'==6 {
	gen remotelearning=.
}

*Social protection	
if `r'==1 {
	gen govtsupport=0 			//R1 assistance from the government over the past year
	replace govtsupport=1 if lc1_gov==1 & lc2_gov_chg==1
}
else {
	rename lc1_gov govtsupport		//Past four weeks
	replace govtsupport=. if govtsupport==-99
}
	rename as1_assist_type_3 cashtransfer
	rename lc1_ngo ngosupport
	gen assistance=1	//assistance in food, cash, or other from government, NGO, or other since outbreak (R1)/over the past 4 weeks (R2-6)
	replace assistance=0 if as1_assist_type=="0"
	replace assistance=. if as1_assist_type=="-98" | as1_assist_type=="-99"

*Regional attribution
gen regid=""
replace regid="ETH.11_1" if region==1
replace regid="ETH.2_1" if region==2
replace regid="ETH.3_1" if region==3
replace regid="ETH.8_1" if region==4
replace regid="ETH.10_1" if region==5
replace regid="ETH.4_1" if region==6
replace regid="ETH.9_1" if region==7
replace regid="ETH.6_1" if region==12
replace regid="ETH.7_1" if region==13
replace regid="ETH.1_1" if region==14
replace regid="ETH.5_1" if region==15

 *Save
keep sex location region regid weight wealth round medicine medicaltreatment fsec remotelearning* govtsupport cashtransfer 
save "prep\ETH_wb_r`r'.dta", replace
}
