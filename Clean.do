*Clean.do

clear all
set more off
*****************************************************************************************************
* ACCESSING LOCAL DIRECTORY WHERE FILES ARE STORED
cd "C:\Program Files\Stata\Project\work-schooling" 
* SAVING FILE DIRECTORY IN LOCAL MACRO
local work_school: dir "`c(pwd)'" file "*p*.dta"

*****************************************************************************************************
*******  DATA CLEANING BY LOOPING THROUGH INDIVIDUAL FILES OF WORK-SCHOOLING SURVEY:  ***************
*****************************************************************************************************
foreach f in `work_school' {
	use `f',clear
	*di "`f'"
	local year = substr("`f'",3,2)
	gen year= "20`year'"
	destring year,replace
	rename *001 paid_work
	rename nomem_encr id
	rename *002 birth_year
	if "`year'"=="19" {
		rename *006 educ
	}
	else {
		rename *005 educ 
		* lot of missing values for 2019
	}
	*SPLITTING EDUCATION LEVEL INTO CATEGORIES
	replace educ=. if educ==0 | educ==28
	replace educ=0 if educ==1 | educ==2
	replace educ=1 if educ==3 | educ==4 | educ==5 | educ==6 | educ==7 | educ==8 | educ==9 | educ==10 | educ==11 | educ==12 | educ==13 | educ==14 | educ==15
	replace educ=2 if educ==16 | educ==17 | educ==18 | educ==19 | educ==20 | educ==21
	replace educ=3 if educ==22 | educ==23 | educ==24 | educ==25 | educ==26
	replace educ=4 if educ==27
	label define educ_level 0 "No Education" 1 "School" 2 "University" 3 "Advanced Degree" 4 "Other"
	label values educ educ_level
	label variable year "Survey Year"
	keep year id birth_year paid_work educ
	save "20`year'_work_school.dta",replace
	*des
}
*********************************************************************************************
* ACCESSING LOCAL DIRECTORY WHERE FILES ARE STORED
cd "C:\Program Files\Stata\Project\ethnic" 
* SAVING FILE DIRECTORY IN LOCAL MACRO
local ethnic: dir "`c(pwd)'" file "*p*.dta" 
*********************************************************************************************
**** DATA CLEANING BY LOOPING THROUGH INDIVIDUAL FILES OF ETHNICITY & RELIGION SURVEY: ******
*********************************************************************************************
foreach f in `ethnic' {
	use `f',clear
	* di "`f'"
	local yr = substr("`f'",3,2)
	gen year= "20`yr'"
	destring year,replace
	rename *079 nationality
	rename nomem_encr id 
	if year<2019 {
	rename *105 abortion 
	}
	else {
	gen abortion =.
	}
	keep year id nationality abortion
	label define yesno 2 "no" 1 "yes" 3 "maybe" 4 "dont know" 
	label define sex 0 "female" 1 "male"
	label values abortion yesno
	label values nationality yesno
	label variable year "Survey Year"
	save "20`yr'_ethnic.dta",replace
}
*********************************************************************************************
* ACCESSING LOCAL DIRECTORY WHERE FILES ARE STORED
cd "C:\Program Files\Stata\Project\family" 
* SAVING FILE DIRECTORY IN LOCAL MACRO
local family: dir "`c(pwd)'" file "*p*.dta" 
*********************************************************************************************
* DATA CLEANING BY LOOPING THROUGH INDIVIDUAL FILES OF FAMILY SURVEY:
*********************************************************************************************
foreach f in `family' {
	use `f',clear
	local filename = substr("`f'",1,5)
	local yr = substr("`f'",3,2)
	gen year= "20`yr'"
	gen child_gender=.
	destring year,replace
	rename nomem_encr id
	rename *003 gender 
	rename *024 partner
	rename *026 partner_birth_year
	rename *032 partner_gender
	if year > 2014 {
		rename *454 temp_kids
		rename *455 kids
	}
	else {
		rename *035 temp_kids
		rename *036 kids
	}
	replace kids=0 if temp_kids==2
	drop temp_kids
	*EXTRACTING GENDER OF SECOND LAST CHILD FROM SURVEY
	local i = 1
	foreach c in "068" "069" "070" "071" "072" "073" "074" "075" "076" "077" "078" "079" "080" "081" "082" { 
	rename `filename'`c' child`i'_gender
	local i = `i' +1 
	}
	*CALCULATING FAMILY SIZE BY GENDER OF LAST CHILD
	foreach c in "15" "14" "13" "12" "11" "10" "9" "8" "7" "6" "5" "4" "3" "2" "1" {
	replace kids=`c' if !missing(child`c'_gender) & missing(kids)
	local j = `c'-1
		if `j'!=0 {
		replace child_gender=child`j'_gender if !missing(child`c'_gender) & missing(child_gender) 
		}
	}	
	rename *385 childcare
	replace partner=0 if partner==2
	replace child_gender=0 if child_gender==2
	replace childcare=0 if childcare==2
	replace childcare=1 if childcare==3
	label define yesno 0 "no" 1 "yes" 2 "maybe" 3 "dont know" 
	label define sex 0 "female" 1 "male"
	label values child_gender sex
	label values partner yesno
	replace gender=0 if gender==2
	replace partner_gender=0 if partner_gender==2
	label values gender sex
	label values partner_gender sex
	label values childcare yesno
	label variable year "Survey Year"
	label variable child_gender "Gender of Second Youngest Child"
	keep year id gender partner partner_birth_year partner_gender child_gender kids childcare
	save "20`yr'_family.dta",replace
}

*********************************************************************************************
* ACCESSING LOCAL DIRECTORY WHERE FILES ARE STORED
cd "C:\Program Files\Stata\Project\income" 
* SAVING FILE DIRECTORY IN LOCAL MACRO
local income: dir "`c(pwd)'" file "*p*.dta" 
*********************************************************************************************
********DATA CLEANING BY LOOPING THROUGH INDIVIDUAL FILES OF INCOME SURVEY:******************
*********************************************************************************************
foreach f in `income' {
	use `f',clear
	di "`f'"
	local year = substr("`f'",3,2)
	gen year= "20`year'"
	destring year,replace
	rename nomem_encr id
	rename *252 fin 
	rename *065 retire
	* 50% drop from 2010-2020
	*rename *008 paid_work
	keep year id fin retire
	replace fin=1 if fin==1 | fin==2 | fin==3
	replace fin=2 if fin==4 | fin==5 
	replace retire=0 if retire==2
	label define yesno 0 "no" 1 "yes" 2 "maybe" 3 "dont know" 
	label define fin_situation 1 "Bad" 2 "Good"
	label values fin fin_situation
	label variable retire "Were you on early retirement ?"
	label values retire yesno
	label variable year "Survey Year"
	save "20`year'_income.dta",replace
}
***********************************************************
*******************END OF PROGRAM**************************
***********************************************************
