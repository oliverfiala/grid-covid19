![Save the Children](https://github.com/oliverfiala/grid-covid19/blob/master/Data/SaveTheChildren.png)
# Methodological note for COVID-19 dashboard in GRID 

### Background 

COVID-19 has dealt an unprecedented blow to lives and livelihoods worldwide.  While children may not be the face of the coronavirus pandemic, they are becoming the biggest victims of its social and economic impacts. There is now a real and present danger that the 2020s will become a ‘lost decade’ of unprecedented reversals in development progress, with devastating consequences for children and their rights.  

The impacts of COVID-19 will not be equally felt, with the world’s poorest and most vulnerable children likely to bear the greatest burden of the socio-economic consequences. To understand better the impacts of COVID-19 and how they affect different groups, we need granular data disaggregated by wealth, location and other dimensions. Unfortunately, the pandemic makes it much harder to collect data with traditional methods such as household surveys, which have been the basis for the data presented in **[GRID, Save the Children’s Child Inequality Tracker](http://www.childinequality.org)**. Innovative solutions, such as widespread phone surveys, can partially close this gap and can provide timely and important insights into the impact COVID-19 on children.  

At Save the Children we are interested in COVID-19’s impact on children’s rights to survive, learn and be protected, as well as safety nets families have access to during these unprecedented times. Data collected by the World Bank through its High-Frequency Phone Surveys as well as by Innovations for Poverty Action through its phone-based RECOVR surveys help us to better understand the socio-economic impacts of COVID-19.  

While all phone surveys were designed to be representative of the underlying population, by their very nature they might under-represent those with poor network connections or limited access to phones. Differences in characteristics of phone owners are likely to create survey-specific biases. It is therefore important to interpret cross-country comparisons or group-specific effects with caution. Furthermore, from a practical perspective, the length of phone surveys limits the breadth and depth of the information that can be collected. More information on sampling strategies and methodology can be found in the [World Bank’s technical note for their COVID-19 High-Frequency Monitoring Dashboard](http://pubdocs.worldbank.org/en/106981605043307033/COVID-19-Dashboard-Technical-Note.pdf). 

### Analysis 

We have harmonised key child-relevant indicators from those phone surveys based on publicly available microdata, using supporting material such as the questionnaires, and we checked our replicated estimates against published findings from the primary analysis.  

As relevant variables vary slightly from survey to survey, definitions are kept broad so as to encompass slightly diverging definitions. Substantial survey-specific diversions from the standard definition are explained more in detail in the [country notes](https://github.com/oliverfiala/grid-covid19/blob/master/GRID_covid19_sources_notes.xlsx) and flagged in the footnotes accompanying the data visualisations. The standard definitions for each indicator are defined as follows: 

* Lack of access to services: households who skipped, delayed, or could not access healthcare services or medical treatment (%) 
* Food insecurity: households experiencing moderate or severe food insecurity (measured according to FAO’s FIES scale) (%) 
* Out of school: households where school-aged children may not return to school (%)  
* Lack of remote learning: households where children are not engaged educational activities during school closures (%) 
* Lack of government support: households that have received no additional assistance (cash, food or other support) from the government in response to COVID-19 (%) 
* Delays in cash transfer: households that have experienced delays or difficulties in receiving cash transfers (%) 

Whenever the microdata allows for it, data is disaggregated by region (usually first subnational administrative level) and location (urban/rural). We further estimated wealth/income groups or distinguished between poor/non-poor households where possible. The [country notes](https://github.com/oliverfiala/grid-covid19/blob/master/GRID_covid19_sources_notes.xlsx) will explain further how this distinction has been made for each survey. 

We estimate the absolute number of children affected by applying the rate to the relevant child population (using UN World Population Prospects 2019). For all health, nutrition, and social protection indicators the relevant child population is the population age 0-17 years, for education indicators the relevant child population has been defined as 5-17 years old. When calculating the number of children affected by levels of disaggregation (location, wealth), we assumed that the distribution of those groups follows the distribution of the sample size in the survey to ensure consistency across our estimates. 

The data analysis was conducted using Stata (Version 15.1). The underlying microdata for all phone surveys can be accessed publicly via [World Bank’s Microdata Library](https://microdata.worldbank.org/index.php/home) (for World Bank’s High-Frequency Phone Surveys) and [Harvard’s Dataverse](https://dataverse.harvard.edu/dataverse/ipa) (for IPA’s RECOVR surveys). 

In this repository, we share the syntax we used to create all estimates used for the COVID-19 dashboard of GRID. More specifically, the analysis has been conducted in three steps: 
1. We prepare each survey for estimation, harmonise variables and indicators, generate the relevant disaggregation dimensions and allocate subnational regions a regional ID connected to the shapefiles we use to illustrate subnational data. In the folder *Syntax*, you can find the relevant do-files for each survey in the format *1_prep_countrycode_survey.do*. Executing the do-files requires the original microdata. 
2. We automatically tabulate the estimates for all possible indicators and disaggregation dimensions based on the data files prepared in step 1. The results can be found in the folder Data as *tabulation.dta*. 
3. Finally, we clean the tabulated data and reshape the data into the relevant format for export to Tableau. We merge population estimates to calculate the absolute number of children affected as well as regional labels to ensure consistent and correct labelling of subnational regions (both files are provided in the *Data* folder). The syntax also drops indicators/levels of disaggregation, which may have tabulated but are not included in the dashboard. We also exclude groups with a sample size below 25. The final results are published as *grid_covid19.csv*, which can be found in the main level of this repository. 

For any questions on the methodology, please contact [Chiara Orlassino](mailto:c.orlassino@savethechildren.org.uk) or [Oliver Fiala](mailto:o.fiala@savethechildren.org.uk).
