*Set working directory
cd "T:\PAC\Research\COVID-19\"


*--- ROUNDS 1-3 ---

forvalues r=1/3 {
if `r'<3 {
	use "source\wb\KEN\hh_ken_c19rrps_w`r'.dta", clear
}
if `r'==3 {
	use "source\wb\KEN\hh_microlibrary_w`r'.dta", clear
	merge 1:m id using "source\wb\KEN\hh_child_microlibrary_w3.dta", nogen
}

gen round=`r'
gen year=2020
gen month=.
if `r'==1 {
	replace month=6
}
if `r'==2 {
	replace month=9
}
if `r'==3 {
	replace month=11
}

*Weights - variable name already weight

*Prepare dataset by renaming & creating variables on interest
gen sex=1
if `r'==1 {
	replace sex=2 if s2_q3_gender==1		//1 Male 2 female
}
if `r'==2 {
	replace sex=2 if s2_q4_gender==1		//1 Male 2 female
}
if `r'==3 {
	replace sex=2 if s1_q4_tr_gender=="Female"
}

gen location=1
if `r'!=3 {
	replace location=2 if s2_q10_mktcentre==0	//1 Urban 2 Rural
	rename s2_q9a_county region
}
if `r'==3 {
	replace location=2 if urban==0
	rename s2_q11a_county region
}

*Wealth disaggregation
if `r'==1 {
	pca s2_q25_ownasset_1 s2_q25_ownasset_2 s2_q25_ownasset_3 s2_q25_ownasset_4
	}
if `r'==2 {
	pca ownasset_1 ownasset_2 ownasset_3 ownasset_4
	}
	if `r'==3 {
	pca s2_q34_ownasset_1 s2_q34_ownasset_2 s2_q34_ownasset_3 s2_q34_ownasset_4
}

*screeplot, yline(1) ci(het)
predict pc1 /*pc2 pc3*/, score 
xtile wealth=pc1[aw=weight], n(5)
gen poverty=.

*Health
gen medicine=.		//	Negative! UNABLE to access - R2 timeframe past week
replace medicine=1 if s9_q10_medsoutstock==0
replace medicine=0 if s9_q10_medsoutstock==1
gen medicaltreatment=.
replace medicaltreatment=1 if s9_q7_accesstreatment==1
replace medicaltreatment=0 if s9_q7_accesstreatment==0

*Education
gen remotelearning=.
gen schoolreturn=.
if `r'==1 {
	rename s3_q10_schoolgo schoolattendance
	rename s3_q10c_accessteacher teacher
	replace remotelearning=1 if s3_q8_school_activity_yn==1
	replace remotelearning=0 if s3_q8_school_activity_yn==0
}
if `r'==2 {
	rename s3_q11_schoolgo schoolattendance
	rename s3_q11d_accessteacher teacher
	replace remotelearning=1 if s3_7_school_activity_yn==1
	replace remotelearning=0 if s3_7_school_activity_yn==0
	replace schoolreturn=1 if s3_q11b_oncereopen==1
	replace schoolreturn=0 if s3_q11b_oncereopen==0
}
if `r'==3 {
	replace schoolreturn=1 if s2c_q4_oncereopen==1 | s2c_q4_oncereopen==2		//Either in school now or planning to go back when it reopens
	replace schoolreturn=0 if s2c_q4_oncereopen==3
	replace remotelearning=0 if s2c_q6_engage_learnact==0		//No timeframe
	replace remotelearning=1 if s2c_q6_engage_learnact==1
	gen schoolattendance=.
	rename s2c_q9_accessteacher teacher
}
	
*Nutrition (FIES scale http://www.fao.org/3/a-as583e.pdf)
gen fies=0
gen fieschild=0
gen fsec=0
gen fsecchild=0
if `r'==1 {
	replace fies=1 if s5_3_q6_worryfood==1	//Mild - 30 days
	replace fies=2 if s5_3_q8a_skippedadult>0	//Moderate - 7 days
	replace fies=3 if (s5_3_q7a_hungryadult>0 | s5_3_q9a_nofoodadult>0)	//Severe - 7 days
	replace fieschild=1 if s5_3_q6_worryfood==1	//Mild - 30 days
	replace fieschild=2 if s5_3_q8b_skippedchild>0	//Moderate - 7 days
	replace fieschild=3 if (s5_3_q7b_hungrychild>0 | s5_3_q9b_nofoodchild>0)	//Severe - 7 days
}
else {
	replace fies=1 if s5_q9_worryfood==1	//Mild - 30 days
	replace fies=2 if s5_q11a_skippedadult>0	//Moderate - 7 days
	replace fies=3 if (s5_q10a_hungryadult>0 | s5_q12a_nofoodadult>0)	//Severe - 7 days
	replace fieschild=fies if fies==1	//Mild - 30 days
	replace fieschild=2 if s5_q11b_skippedchild>0	//Moderate - 7 days
	replace fieschild=3 if (s5_q10b_hungrychild>0 | s5_q12b_nofoodchild>0)	//Severe - 7 days
}
if 	`r'==3 {
	replace fies=3 if s5_q6_hunger==1
}
replace fsec=1 if fies==2 | fies==3
replace fsecchild=1 if fieschild==2 | fieschild==3

*Social protection
gen govtsupport=.		//Timeframe past 14 days
replace govtsupport=1 if s7_q4_govthelp==1 | s7_q4_govthelp==2
replace govtsupport=0 if s7_q4_govthelp==0
rename s7_q5_ngohelp ngosupport 	//Timeframe past 14 days
rename s7_q6_politicianhelp govtrepsupport		//Timeframe past 14 days

*Income loss
gen jobloss=.
if `r'==1 {
	replace jobloss=0		//Any household member was laid off
	replace jobloss=1 if s4_q33_wholaidoff__0==0
}
if `r'==2 {
	replace jobloss=1		//Any adult household member was laid off since January 2020
	replace jobloss=0 if s4_q36_wholaidoff=="-98"
}

*Regional attribution
label define region 1 "Mombasa" 2 "Kwale" 3 "Kilifi" 4 "Tana River" 5 "Lamu" 6 "Taita-Taveta" 7 "Garissa" 8 "Wajir" 9 "Mandera" 10 "Marsabit" /*
*/ 11 "Isiolo" 12 "Meru" 13 "Tharaka-Nithi" 14 "Embu" 15 "Kitui" 16 "Machakos" 17 "Makueni" 18 "Nyandarua" 19 "Nyeri" 20 "Kirinyaga" /*
*/ 21 "Muranga" 22 "Kiambu" 23 "Turkana" 24 "West Pokot" 25 "Samburu" 26 "Trans-Nzoia" 27 "Uasin-Gishu" 28 "Elgeyo-Marakwet" 29 "Nandi" 30 "Baringo" /*
*/ 31 "Laikipia" 32 "Nakuru" 33 "Narok" 34 "Kajiado" 35 "Kericho" 36 "Bomet" 37 "Kakamega" 38 "Vihiga" 39 "Bungoma" /*
*/ 40 "Busia" 41 "Siaya" 42 "Kisumu" 43 "Homa Bay" 44 "Migori" 45 "Kisii" 46 "Nyamira" 47 "Nairobi" 
label values region region
gen regid=""

replace regid="KEN.28_1" if region==1
replace regid="KEN.19_1" if region==2
replace regid="KEN.14_1" if region==3
replace regid="KEN.40_1" if region==4
replace regid="KEN.21_1" if region==5
replace regid="KEN.39_1" if region==6
replace regid="KEN.7_1" if region==7
replace regid="KEN.46_1" if region==8
replace regid="KEN.24_1" if region==9
replace regid="KEN.25_1" if region==10
replace regid="KEN.9_1" if region==11
replace regid="KEN.26_1" if region==12
replace regid="KEN.41_1" if region==13
replace regid="KEN.6_1" if region==14
replace regid="KEN.18_1" if region==15
replace regid="KEN.22_1" if region==16
replace regid="KEN.23_1" if region==17
replace regid="KEN.35_1" if region==18
replace regid="KEN.36_1" if region==19
replace regid="KEN.15_1" if region==20
replace regid="KEN.29_1" if region==21
replace regid="KEN.13_1" if region==22
replace regid="KEN.43_1" if region==23
replace regid="KEN.47_1" if region==24
replace regid="KEN.37_1" if region==25
replace regid="KEN.42_1" if region==26
replace regid="KEN.44_1" if region==27
replace regid="KEN.5_1" if region==28
replace regid="KEN.32_1" if region==29
replace regid="KEN.1_1" if region==30
replace regid="KEN.20_1" if region==31
replace regid="KEN.31_1" if region==32
replace regid="KEN.33_1" if region==33
replace regid="KEN.10_1" if region==34
replace regid="KEN.12_1" if region==35
replace regid="KEN.2_1" if region==36
replace regid="KEN.11_1" if region==37
replace regid="KEN.45_1" if region==38
replace regid="KEN.3_1" if region==39
replace regid="KEN.4_1" if region==40
replace regid="KEN.38_1" if region==41
replace regid="KEN.17_1" if region==42
replace regid="KEN.8_1" if region==43
replace regid="KEN.27_1" if region==44
replace regid="KEN.16_1" if region==45
replace regid="KEN.34_1" if region==46
replace regid="KEN.30_1" if region==47

*Label
label define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values month month

*Save
keep sex location region regid wealth poverty medicine medicaltreatment fsec schoolattendance schoolreturn teacher remotelearning govtsupport jobloss weight round year month
save "prep\KEN_wb_r`r'.dta", replace
}
