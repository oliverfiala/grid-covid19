*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"


*--- ROUND 4 ---

use "source\wb\NGA\r4_sect_11.dta", clear
duplicates list hhid
duplicates drop hhid, force
merge 1:1 hhid using "source\wb\NGA\r4_sect_a_2_5_5b_6_8_9_12.dta", nogen

*Weights
rename wt_round4 weight

*Prepare dataset by renaming & creating variables on interest
rename sector location		//1 urban 2 rural
rename state region
gen sex=.
gen wealth=.

*Health
gen medicaltreatment=.	//7 days
replace medicaltreatment=1 if s5q3==1
replace medicaltreatment=0 if s5q3==2

gen natalcare=.
replace natalcare=1 if s5q2b==1
replace natalcare=0 if s5q2b==2

*Food security
gen fies=.
replace fies=0 if s8q1==2 & s8q2==2 & s8q3==2 & s8q4==2 & s8q5==2 & s8q6==2 & s8q7==2 & s8q8==2
replace fies=1 if s8q1==1 | s8q2==1 | s8q3==1
replace fies=2 if s8q4==1 | s8q5==1 | s8q6==1
replace fies=3 if s8q7==1 | s8q8==1
gen fsec=.
replace fsec=0 if fies==0 | fies==1
replace fsec=1 if fies==2 | fies==3

*Education
gen remotelearning=.		//7 days
replace remotelearning=1 if s5q4b==1
replace remotelearning=0 if s5q4b==2
gen schoolreturn=.
replace schoolreturn=1 if s5q5c==1
replace schoolreturn=0 if s5q5c==2 | s5q5c==3
gen schoolattendance=.
replace schoolattendance=1 if s5q5b==1
replace schoolattendance=0 if s5q5b==2

*Social protection
gen assistance=.		//Any kind of assistance since last call
replace assistance=1 if s11q1==1
replace assistance=0 if s11q1==2
ren assistance govtsupport

*Regional attribution
gen regid=""
replace regid="NG.AB" if region==1
replace regid="NG.AD" if region==2
replace regid="NG.AK" if region==3
replace regid="NG.AN" if region==4
replace regid="NG.BA" if region==5
replace regid="NG.BY" if region==6
replace regid="NG.BE" if region==7
replace regid="NG.BO" if region==8
replace regid="NG.CR" if region==9
replace regid="NG.DE" if region==10
replace regid="NG.EB" if region==11
replace regid="NG.ED" if region==12
replace regid="NG.EK" if region==13
replace regid="NG.EN" if region==14
replace regid="NG.GO" if region==15
replace regid="NG.IM" if region==16
replace regid="NG.JI" if region==17
replace regid="NG.KD" if region==18
replace regid="NG.KN" if region==19
replace regid="NG.KT" if region==20
replace regid="NG.KE" if region==21
replace regid="NG.KO" if region==22
replace regid="NG.KW" if region==23
replace regid="NG.LA" if region==24
replace regid="NG.NA" if region==25
replace regid="NG.NI" if region==26
replace regid="NG.OG" if region==27
replace regid="NG.ON" if region==28
replace regid="NG.OS" if region==29
replace regid="NG.OY" if region==30
replace regid="NG.PL" if region==31
replace regid="NG.RI" if region==32
replace regid="NG.SO" if region==33
replace regid="NG.TA" if region==34
replace regid="NG.YO" if region==35
replace regid="NG.ZA" if region==36
replace regid="NG.FC" if region==37

*Save
keep sex location region regid wealth weight natalcare medicaltreatment fsec remotelearning schoolreturn schoolattendance govtsupport 
save "prep\NGA_wb_r4.dta", replace
