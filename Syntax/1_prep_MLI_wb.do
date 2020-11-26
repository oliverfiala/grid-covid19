*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*--- ROUND 3 ---

*Prepare health seeking behaviour file
use "source\wb\MLI\round3_s04_services_sante.dta", clear
egen x=max(s04q04), by(hhid)
duplicates drop hhid, force
gen medicaltreatment=1 if x==1
replace medicaltreatment=0 if x==2
tempfile round3_s04_services_sante
save `round3_s04_services_sante', replace

*Open surveys and merge with health seeking behaviour
use "source\wb\MLI\round3_s04_acces_covid.dta", clear
merge 1:1 hhid using "source\wb\MLI\round3_s06_insecu_alim.dta", nogen	
merge 1:1 hhid using "source\wb\MLI\round3_s05_emploi_revenu_covid.dta", nogen	
merge 1:1 hhid using `round3_s04_services_sante', nogen	keepusing(medicaltreatment)

*Weights
rename hhweight_covid weight

*Prepare dataset by renaming & creating variables on interest
gen location=1
replace location=2 if domaine_residence==2	//1 Urban 2 Rural
*region already there
gen poor=0
replace poor=1 if p0==100
gen sex=.
gen wealth=.

*Health
gen medicine=.
replace medicine=1 if s04q01a==1
replace medicine=0 if s04q01a==2
	*Q on medical treatment in round3_s04_services_sante.dat

*Education
gen schoolreturn=.
replace schoolreturn=1 if s04q11a==1
replace schoolreturn=0 if s04q11a==2 | s04q11a==3

*Nutrition (FIES scale http://www.fao.org/3/a-as583e.pdf) - No timeframe
gen fies=1		//Mild
replace fies=0 if s06q05+s06q06+s06q07+s06q08+s06q09+s06q10+s06q11+s06q11==16
replace fies=2 if (s06q08==1 | s06q09==1 | s06q10==1) //Moderate
replace fies=3 if (s06q11==1 | s06q12==1) //Severe
gen fsec=0
replace fsec=1 if fies==2 | fies==3
gen fiescovid=0
replace fiescovid=0 if s06q05a+s06q06a+s06q07a+s06q08a+s06q09a+s06q10a+s06q11a+s06q11a==16	//None
replace fiescovid=1 if (s06q05==1 & s06q05a==1) | (s06q06==1 & s06q06a==1) | (s06q07==1 & s06q07a==1)	//Mild
replace fiescovid=2 if (s06q08==1 & s06q08a==1) | (s06q09==1 & s06q09a==1) | (s06q10==1 & s06q10a==1) //Moderate
replace fiescovid=3 if (s06q11==1 & s06q11a==1) | (s06q12==1 & s06q12a==1)		//Severe
gen fseccovid=0
replace fseccovid=1 if fiescovid==2 | fiescovid==3

*Social protection
gen govtsupport=.		//Support from govt or other over the past month
replace govtsupport=1 if s05q20==1
replace govtsupport=0 if s05q20==2

*Regional attribution
gen regid=""
replace region=6 if region==10	// Taoudénit is a region of Mali legislatively created in 2012 from the northern part of Timbuktu Cercle in Tombouctou Region
replace region=7 if region==11	// Menaka is part of Gao in shapefile
replace regid="MLDHS2018427002" if region==1
replace regid="MLDHS2018427003" if region==2
replace regid="MLDHS2018427005" if region==3
replace regid="MLDHS2018427006" if region==4
replace regid="MLDHS2018427008" if region==5
replace regid="MLDHS2018427013" if region==6
replace regid="MLDHS2018427012" if region==7
replace regid="MLDHS2018427011" if region==8
replace regid="MLDHS2018427014" if region==9

*Save
keep sex location region regid wealth poor medicine medicaltreatment schoolreturn fsec fseccovid govtsupport
save "prep\MLI_wb_r3.dta", replace
