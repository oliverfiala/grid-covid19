*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"


*--- ROUND 5 ---

use "source\wb\ETH\r5_wb_lsms_hfpm_hh_survey_public_microdata_Non20.dta", clear

*Weights
rename phw5 weight

*Prepare dataset by renaming & creating variables on interest
rename cs1_region region
gen location=1
replace location=2 if cs4_sector==1	//Urban 1 rural 2
rename ii4_resp_gender sex	 		//Male 1 female 2
rename ii4_resp_age age
gen wealth=.

*Health
rename ac7_med_access medicaltreatment
gen medicine=.
replace medicine=1 if ac1_atb_med==1
replace medicine=0 if ac1_atb_med==0

*Food security
*Nutrition (FIES scale - 30 days - http://www.fao.org/3/a-as583e.pdf)
gen fies=.
replace fies=0 if fi1_enough==0 & fi2_healthy==0 & fi3_fewkinds==0 & fi4_skipmeal==0 & fi5_ateless==0 & fi6_noteatfullday==0 & fi7_outoffood==0 & fi8_hungrynoteat==0
replace fies=1 if fi1_enough==1 | fi2_healthy==1 | fi3_fewkinds==1
replace fies=2 if fi4_skipmeal==1 | fi5_ateless==1 | fi6_noteatfullday==1
replace fies=3 if fi7_outoffood==1 | fi8_hungrynoteat==1
gen fsec=.
replace fsec=0 if fies==0 | fies==1
replace fsec=1 if fies==2 | fies==3

*Education
gen remotelearning_primary=.
replace remotelearning_primary=1 if ac4a_pri_child==1
replace remotelearning_primary=0 if ac4a_pri_child==0
rename ac4b_sec_child remotelearning_secondary
*replace remotelearning_secondary=. if remotelearning_secondary==-98

*Social protection	//Past four weeks
rename lc1_gov govtsupport
rename as1_assist_type_3 cashtransfer
rename lc1_ngo ngosupport
gen assistance=1	//assistance in food, cash, or other from government, NGO, or other over the past 4 weeks
replace assistance=0 if as1_assist_type=="0"
replace assistance=. if as1_assist_type=="-98"

*Regional attribution
gen regid=""
replace regid="ET.TI" if region==1
replace regid="ET.AF" if region==2
replace regid="ET.AM" if region==3
replace regid="ET.OR" if region==4
replace regid="ET.SO" if region==5
replace regid="ET.BE" if region==6
replace regid="ET.SN" if region==7
replace regid="ET.GA" if region==12
replace regid="ET.HA" if region==13
replace regid="ET.AA" if region==14
replace regid="ET.DD" if region==15

 *Save
keep sex location region regid weight wealth medicine medicaltreatment fsec remotelearning* govtsupport cashtransfer
save "prep\ETH_wb_r5.dta", replace
