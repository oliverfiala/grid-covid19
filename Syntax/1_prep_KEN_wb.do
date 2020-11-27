*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*--- ROUND 1 ---

use "source\wb\KEN\hh_ken_c19rrps_w1.dta", clear

*Weights - variable name already weight

*Prepare dataset by renaming & creating variables on interest
gen sex=1
replace sex=2 if s2_q3_gender==1		//1 Male 2 female
rename s3_q8_school_activity_yn schoolchildren
gen location=1
replace location=2 if s2_q10_mktcentre==0	//1 Urban 2 Rural
rename s2_q9a_county region
gen wealth=.

*Health
gen medicine=.		//	Negative! UNABLE to access
replace medicine=1 if s9_q10_medsoutstock==0
replace medicine=0 if s9_q10_medsoutstock==1
gen medicaltreatment=.
replace medicaltreatment=1 if s9_q7_accesstreatment==1
replace medicaltreatment=0 if s9_q7_accesstreatment==0

*Education
rename s3_q10_schoolgo schoolattendance
rename s3_q10c_accessteacher teacher
gen remotelearning=.
replace remotelearning=1 if s3_q13_childlearning__0==0
replace remotelearning=0 if s3_q13_childlearning__0==1

*Nutrition (FIES scale http://www.fao.org/3/a-as583e.pdf)
gen fies=0
replace fies=1 if s5_3_q6_worryfood==1	//Mild - 30 days
replace fies=2 if s5_3_q8a_skippedadult>0	//Moderate - 7 days
replace fies=3 if (s5_3_q7a_hungryadult>0 | s5_3_q9a_nofoodadult>0)	//Severe - 7 days
gen fieschild=0
replace fieschild=1 if s5_3_q6_worryfood==1	//Mild - 30 days
replace fieschild=2 if s5_3_q8b_skippedchild>0	//Moderate - 7 days
replace fieschild=3 if (s5_3_q7b_hungrychild>0 | s5_3_q9b_nofoodchild>0)	//Severe - 7 days
gen fsec=0
replace fsec=1 if fies==2 | fies==3
gen fsecchild=0
replace fsecchild=1 if fieschild==2 | fieschild==3

*Social protection
gen govtsupport=.
replace govtsupport=1 if s7_q4_govthelp==1 | s7_q4_govthelp==2
replace govtsupport=0 if s7_q4_govthelp==0
rename s7_q5_ngohelp ngosupport
rename s7_q6_politicianhelp govtrepsupport

*Regional attribution
label define region 1 "Mombasa" 2 "Kwale" 3 "Kilifi" 4 "Tana River" 5 "Lamu" 6 "Taita-Taveta" 7 "Garissa" 8 "Wajir" 9 "Mandera" 10 "Marsabit" /*
*/ 11 "Isiolo" 12 "Meru" 13 "Tharaka-Nithi" 14 "Embu" 15 "Kitui" 16 "Machakos" 17 "Makueni" 18 "Nyandarua" 19 "Nyeri" 20 "Kirinyaga" /*
*/ 21 "Muranga" 22 "Kiambu" 23 "Turkana" 24 "West Pokot" 25 "Samburu" 26 "Trans-Nzoia" 27 "Uasin-Gishu" 28 "Elgeyo-Marakwet" 29 "Nandi" 30 "Baringo" /*
*/ 31 "Laikipia" 32 "Nakuru" 33 "Narok" 34 "Kajiado" 35 "Kericho" 36 "Bomet" 37 "Kakamega" 38 "Vihiga" 39 "Bungoma" /*
*/ 40 "Busia" 41 "Siaya" 42 "Kisumu" 43 "Homa Bay" 44 "Migori" 45 "Kisii" 46 "Nyamira" 47 "Nairobi" 
label values region region
gen regid=""
replace regid="KE.MM" if region==1
replace regid="KE.KW" if region==2
replace regid="KE.KF" if region==3
replace regid="KE.TR" if region==4
replace regid="KE.LM" if region==5
replace regid="KE.TT" if region==6
replace regid="KE.GA" if region==7
replace regid="KE.WJ" if region==8
replace regid="KE.MD" if region==9
replace regid="KE.MB" if region==10
replace regid="KE.IS" if region==11
replace regid="KE.ME" if region==12
replace regid="KE.NT" if region==13
replace regid="KE.EB" if region==14
replace regid="KE.KT" if region==15
replace regid="KE.MC" if region==16
replace regid="KE.MK" if region==17
replace regid="KE.NN" if region==18
replace regid="KE.NI" if region==19
replace regid="KE.KY" if region==20
replace regid="KE.MU" if region==21
replace regid="KE.KB" if region==22
replace regid="KE.TU" if region==23
replace regid="KE.WP" if region==24
replace regid="KE.SA" if region==25
replace regid="KE.TN" if region==26
replace regid="KE.UG" if region==27
replace regid="KE.EM" if region==28
replace regid="KE.ND" if region==29
replace regid="KE.BA" if region==30
replace regid="KE.LK" if region==31
replace regid="KE.NK" if region==32
replace regid="KE.NR" if region==33
replace regid="KE.KJ" if region==34
replace regid="KE.KR" if region==35
replace regid="KE.BO" if region==36
replace regid="KE.KK" if region==37
replace regid="KE.VI" if region==38
replace regid="KE.BN" if region==39
replace regid="KE.BS" if region==40
replace regid="KE.SI" if region==41
replace regid="KE.KU" if region==42
replace regid="KE.HB" if region==43
replace regid="KE.MG" if region==44
replace regid="KE.KI" if region==45
replace regid="KE.NM" if region==46
replace regid="KE.NB" if region==47

*Save
keep sex location region regid wealth medicine medicaltreatment fsec schoolattendance teacher remotelearning govtsupport weight
save "prep\KEN_wb_r1.dta", replace
