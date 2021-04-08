*Set working directory
cd "T:\PAC\Research\COVID-19\"

*Import data from World Bank COVID-19 High-Frequency Monitoring Dashboard
*import excel using "https://pubdocs.worldbank.org/en/852181605043954639/COVID-19-Dashboard-Data-Latest.xlsx", sheet("2. Harmonized Indicators") firstrow case(lower) clear
import excel using "https://development-data-hub-s3-public.s3.amazonaws.com/ddhfiles/1235981/formatted_data15-mar-2021_external.xlsx", sheet("2. Harmonized Indicators") firstrow case(lower) clear
keep if /*gender=="All" & */urban_rural=="National" & industry=="All"
drop if income_group=="High income"
ren code countrycode
gen round=substr(wave,-1,.)
destring round, replace
keep if indicator=="Heal_rece" | indicator=="Educ_any" | indicator=="Safe_gover"
replace indicator="healthseeking" if indicator=="Heal_rece"
replace indicator_val=100-indicator_val if indicator=="healthseeking"
replace indicator="remotelearning" if indicator=="Educ_any"
replace indicator="govtsupport" if indicator=="Safe_gover"
keep countrycode round month year indicator indicator_val sample_subset
reshape wide indicator_val sample_subset, i(countrycode round) j(indicator) string
gen source="wb"
gen group="all"
gen groupvalue=.
save "dat/wb_dashboard.dta", replace
