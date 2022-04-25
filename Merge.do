*Merge.do

clear all
set more off
*SETTING LOCAL OUTPUT DIRECTORY
local output "C:\Program Files\Stata\Project\output"
*******************************************************************
****COMBINING LONGITUDINAL DATA OF WORK SCHOOLING SURVEYS 2008-2020
*******************************************************************
cd "C:\Program Files\Stata\Project\work-schooling"
local work_school: dir "`c(pwd)'" file "*work_school.dta"
use combine.dta,clear
drop _all
foreach f in `work_school' {
	di "`f'"
	append using `f'
}
order id year educ paid_work birth_year
sort id year 
*FILLING IN MISSING VALUES
bysort id: replace birth_year=birth_year[1] if missing(birth_year) & !missing(birth_year[1])
replace birth_year=year-birth_year
rename birth_year age
replace educ = educ[_n-1] if missing(educ) & !missing(educ[_n-1]) & id==id[_n-1] & year==2019
label variable age "Respondents Age"
*SAVING COMBINED DTA IN OUTPUT FOLDER
save "`output'\ws_combine.dta",replace 
misstable sum,all
***********************************************************************
*COMBINING LONGITUDINAL DATA OF RELIGION & ETHNICITY SURVEYS 2008-2020*
***********************************************************************
cd "C:\Program Files\Stata\Project\ethnic"
local ethnic: dir "`c(pwd)'" file "*ethnic.dta"
use combine.dta,clear
drop _all
foreach f in `ethnic' {
	di "`f'"
	append using `f'
  }
order id year nationality abortion
sort id year
*FILLING IN MISSING VALUES:
bysort id: replace nationality=nationality[1] if missing(nationality) & !missing(nationality[1])
replace abortion = abortion[_n-1] if missing(abortion) & !missing(abortion[_n-1]) & id==id[_n-1] & year>2018
*SAVING COMBINED DTA IN OUTPUT FOLDER
save "`output'\ethnic_combine.dta",replace
misstable sum,all
********************************************************************
***COMBINING LONGITUDINAL DATA OF WORK-SCHOOLING SURVEYS 2008-2020**
********************************************************************
cd "C:\Program Files\Stata\Project\family"
local family: dir "`c(pwd)'" file "*family.dta"
use combine.dta,clear
drop _all
foreach f in `family' {
	di "`f'"
	append using `f'
}
order id year gender partner partner_birth_year partner_gender kids child_gender
sort id year
*FILLING IN MISSING VALUES:
bysort id: replace gender=gender[1] if missing(gender) & !missing(gender[1])
replace partner_birth_year=year-partner_birth_year
rename partner_birth_year partner_age
label variable partner_age "Respondents Partners Age"
*SAVING COMBINED DTA IN OUTPUT FOLDER
save "`output'\family_combine.dta",replace
misstable sum,all
****************************************************************
****COMBINING LONGITUDINAL DATA OF INCOME SURVEYS 2008-2020*****
****************************************************************
cd "C:\Program Files\Stata\Project\income"
local income: dir "`c(pwd)'" file "*income.dta"
use combine.dta,clear
drop _all
foreach f in `income' {
	di "`f'"
	append using `f'
}
order id year fin
sort id year
*SAVING COMBINED DTA IN OUTPUT FOLDER
save "`output'\income_combine.dta",replace
misstable sum,all
***********************************************************
****MERGING ALL 4 SURVEY DATA INTO SINGLE PANEL DATASET****
***********************************************************
cd "`output'"
clear all
gen id=.
gen year=.
save combine.dta,replace
local combine: dir "`c(pwd)'" file "*_combine.dta"
foreach f in `combine'{
        use `f', clear
        merge 1:1 id year using combine.dta, nogenerate
        save combine.dta, replace
}
des
sum
*****************************END***************************