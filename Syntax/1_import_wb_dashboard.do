*Set working directory
cd "S:\Advocacy Division\GPAR Department\Inclusive Development\Research\COVID-19\"

*Import data from World Bank COVID-19 High-Frequency Monitoring Dashboard
import excel using "http://pubdocs.worldbank.org/en/852181605043954639/COVID-19-Dashboard-Data-Latest.xlsx", sheet("2. Harmonized Indicators") firstrow case(lower) clear
keep if gender=="All" & urbanrural=="National" & industry=="All"
drop if incomegroup=="High income"
ren code countrycode
gen round=substr(wave,-1,.)
destring round, replace
keep if indicator=="Heal_rece" | indicator=="Educ_any" | indicator=="Safe_gover"
replace indicator="healthseeking" if indicator=="Heal_rece"
replace indicator_val=100-indicator_val if indicator=="healthseeking"
replace indicator="remotelearning" if indicator=="Educ_any"
replace indicator="govtsupport" if indicator=="Safe_gover"
keep countrycode round month year indicator indicator_val sample_s
reshape wide indicator_val sample_s, i(countrycode round) j(indicator) string
gen source="wb"
gen group="all"
gen groupvalue=.
save "dat/wb_dashboard.dta", replace
