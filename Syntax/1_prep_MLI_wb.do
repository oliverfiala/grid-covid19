*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*--- ROUNDS 1-5 ---

forvalues r=1/5 {
*Prepare health seeking behaviour files
if `r'==3 {
	use "source\wb\MLI\round3_s04_services_sante.dta", clear
	egen x=max(s04q04), by(hhid)
	duplicates drop hhid, force
	gen medicaltreatment=1 if x==1
	replace medicaltreatment=0 if x==2
	tempfile round3_s04_services_sante
	save `round3_s04_services_sante', replace
}
if `r'==4 | `r'==5 {
	use "source\wb\MLI\round`r'_s4_services_sante.dta", clear
	duplicates drop hhid, force
	rename acces_traitement medicaltreatment 		//Timeframe past 30 days
	rename acces_pharmacie medicine					//Access to a pharmacy over the past 30 days
	rename acces_planif contraception		//Access to family planning over past 30 days
	rename acces_vaccin immunization	//Access to vaccination over past 30 days
	rename acces_matern	natalcare 	//Access to maternal health services over past 30 days
	tempfile round`r'_s4_services_sante
	save `round`r'_s4_services_sante', replace
}
if `r'==1 | `r'==2 | `r'==3 {
	*Prepare income loss file
	use "source\wb\MLI\round`r'_s08_perte_revenu.dta", clear
	duplicates drop hhid, force
	gen incomeloss=0 if s08q02<=2		//Since mid-March/beginning of the pandemic
	replace incomeloss=1 if s08q02>=3
	tempfile round`r'_s08_perte_revenu
	save `round`r'_s08_perte_revenu', replace
}
if `r'==4 | `r'==5 {
	*Prepare region disaggregation
	use "source\wb\MLI\round`r'_s01_membres.dta", clear
	duplicates drop hhid, force
	tempfile round`r'_s01_membres
	save `round`r'_s01_membres', replace
}
	*Open surveys and merge with health seeking behaviour and income loss
if `r'!=5 {
	use "source\wb\MLI\round`r'_s04_acces_covid.dta", clear		//Health, education
	merge 1:1 hhid using "source\wb\MLI\round`r'_s06_insecu_alim.dta", nogen		//Food insecurity
}
if `r'==1 | `r'==2 | `r'==3 {
	merge 1:1 hhid using "source\wb\MLI\round`r'_s05_emploi_revenu_covid.dta", nogen
	merge 1:1 hhid using `round`r'_s08_perte_revenu', nogen	keepusing(incomeloss)
} /*
if `r'==2 {
	merge 1:1 hhid using `round3_s04_services_sante', nogen	keepusing(region)
	} */
if `r'==3 {
	merge 1:1 hhid using `round3_s04_services_sante', nogen	keepusing(medicaltreatment)
	}
if `r'==4 {
	merge 1:1 hhid using `round`r'_s4_services_sante', nogen keepusing(medicaltreatment medicine /*contraception immunization natalcare*/)
	merge 1:1 hhid using `round`r'_s01_membres', nogen keepusing(region)
}
if `r'==5 {
	use `round`r'_s4_services_sante', clear
	merge 1:1 hhid using `round`r'_s01_membres', nogen keepusing(region)
}

gen round=`r'

*Weights
rename hhweight_covid weight

*Prepare dataset by renaming & creating variables of interest
gen location=1
replace location=2 if domaine_residence==2	//1 Urban 2 Rural
gen poor=0
replace poor=1 if p0==100 | p0==1
gen sex=.
gen wealth=.
if `r'==2 {
	gen region=.
}
*region already there for other rounds

*Health
if `r'!=4 & `r'!=5 {
	gen medicine=.		//Timeframe past week
	replace medicine=1 if s04q01a==1
	replace medicine=0 if s04q01a==2
}
if `r'==1 | `r'==2 {
	gen medicaltreatment=.
}

*Education
gen schoolreturn=.
gen teacher=.
gen remotelearning=.
if `r'==1 {	
	replace remotelearning=1 if  s04q08==1	//Only if all children in household are engaged in remote learning activities
	replace remotelearning=0 if  s04q08==2 |  s04q08==3
	
	replace teacher=1 if s04q10==1
	replace teacher=0 if s04q10==2
}
if `r'==3 {
	replace schoolreturn=1 if s04q11a==1
	replace schoolreturn=0 if s04q11a==2 | s04q11a==3
}
if `r'==4 {
	replace schoolreturn=ts_enfant
}

*Nutrition (FIES scale http://www.fao.org/3/a-as583e.pdf) - No timeframe
gen fies=1		//Mild
gen fsec=0
gen fiescovid=0
gen fseccovid=0
if `r'!=4 & `r'!=5 {
	replace fies=0 if s06q05+s06q06+s06q07+s06q08+s06q09+s06q10+s06q11+s06q11==16
	replace fies=2 if (s06q08==1 | s06q09==1 | s06q10==1) //Moderate
	replace fies=3 if (s06q11==1 | s06q12==1) //Severe
	replace fiescovid=0 if s06q05a+s06q06a+s06q07a+s06q08a+s06q09a+s06q10a+s06q11a+s06q11a==16	//None
	replace fiescovid=1 if (s06q05==1 & s06q05a==1) | (s06q06==1 & s06q06a==1) | (s06q07==1 & s06q07a==1)	//Mild
	replace fiescovid=2 if (s06q08==1 & s06q08a==1) | (s06q09==1 & s06q09a==1) | (s06q10==1 & s06q10a==1) //Moderate
	replace fiescovid=3 if (s06q11==1 & s06q11a==1) | (s06q12==1 & s06q12a==1)		//Severe
}
if `r'==4 {
	replace fies=0 if inquietude+nourriture_pas_bonne+meme_nourriture+sauter_un_repas+pas_assez+no_food_home+faim+faim==0
	replace fies=2 if (sauter_un_repas==1 | pas_assez==1 | no_food_home==1) //Moderate
	replace fies=3 if (faim==1 | no_eat==1) //Severe
	replace fiescovid=0 if inquietude_covid+nourriture_pas_bonne_covid+meme_nourriture_covid+sauter_un_repas_covid+pas_assez_covid+no_food_home_covid+faim_covid+faim_covid==0	//None
	replace fiescovid=1 if (inquietude==1 & inquietude_covid==1) | (nourriture_pas_bonne==1 & nourriture_pas_bonne_covid==1) | (meme_nourriture==1 & meme_nourriture_covid==1)	//Mild
	replace fiescovid=2 if (sauter_un_repas==1 & sauter_un_repas_covid==1) | (pas_assez==1 & pas_assez_covid==1) | (no_food_home==1 & no_food_home_covid==1) //Moderate
	replace fiescovid=3 if (faim==1 & faim_covid==1) | (no_eat==1 & no_eat_covid==1)		//Severe
}
replace fsec=1 if fies==2 | fies==3
replace fseccovid=1 if fiescovid==2 | fiescovid==3
if `r'==5 {
	replace fies=.
	replace fiescovid=.
	replace fsec=.
	replace fseccovid=.
}

*Social protection
gen govtsupport=.
if `r'!=4 & `r'!=5 {
replace govtsupport=1 if s05q20==1		//Support from govt or other over the past month
replace govtsupport=0 if s05q20==2
}

*Regional attribution
gen regid=""
replace region=6 if region==10	// Taoudénit is a region of Mali legislatively created in 2012 from the northern part of Timbuktu Cercle in Tombouctou Region
replace region=7 if region==11	// Menaka is part of Gao in shapefile
replace regid="MLI.3_1" if region==1
replace regid="MLI.5_1" if region==2
replace regid="MLI.8_1" if region==3
replace regid="MLI.7_1" if region==4
replace regid="MLI.6_1" if region==5
replace regid="MLI.9_1" if region==6
replace regid="MLI.2_1" if region==7
replace regid="MLI.4_1" if region==8
replace regid="MLI.1_1" if region==9

*Save
keep sex location region regid wealth poor medicine medicaltreatment remotelearning schoolreturn teacher fsec fseccovid govtsupport weight
save "prep\MLI_wb_r`r'.dta", replace
}
