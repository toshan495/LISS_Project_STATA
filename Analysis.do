*Analysis.do

clear all
* SETTING LOCAL OUTPUT DIRECTORY
local output "C:\Program Files\Stata\Project\output"
cd "`output'"

use combine.dta
drop if age<20 | age>60
save combine.dta, replace

*PLOTTING YEARWISE DISTRIBUTION OF EMPLOYMENT STATUS
catplot fin year, percent(year) asyvars stack
catplot paid_work year, percent(year) asyvars stack recast(bar)


*PLOTTING PANEL COUNT OF EACH UNIQUE INDIVIDUAL
preserve
egen sum=count by(id)
gen tel=1
egen stel=sum(tel),by(id)
collapse stel=stel,by(id)
histogram stel, discrete frequency addlabel xtitle(Panel Count)
graph export Panel_Attrition.png, as(png) replace
restore

*EXPLORATORY DATA ANALYSIS ON TIME INVARIANT VARIABLES
preserve
collapse (max) nationality gender educ kids child_gender childcare (mean) age, by(id)

label define country 0 "Not Dutch" 1 "Dutch"
label values nationality country
label define sex 0 "female" 1 "male"
label values gender sex
label values child_gender sex
label define yesno 0 "no" 1 "yes"
label values childcare yesno
label define educ_level 0 "No Education" 1 "School" 2 "University" 3 "Advanced Degree" 4 "Other"
label values educ educ_level
tab1 nationality gender educ child_gender childcare kids

*PLOTTING AGE DISTRIBUTION OF RESPONDENTS
kdensity age, xtitle(Age of Respondent)
graph export Age_Dist.png, as(png) replace

*PLOTTING FAMILY SIZE OF RESPONDENTS
histogram kids, discrete frequency addlabel xtitle(Family Size)
graph export Family_Size.png, as(png) replace

*LINEAR REGRESSION - DEPENDENT VARIABLE:KIDS, REGRESSOR - MAXIMUM EDUCATION ATTAINED 
regress kids i.educ
* FINDING DIFFERENCE OF MEANS BY LAST CHILD GENDER
ranksum kids, by(child_gender)
tab child_gender,sum(kids)
* FINDING DIFFERENCE OF MEANS BY NATIONALITY
ranksum kids, by(nationality)
tab nationality,sum(kids)
* FINDING DIFFERENCE OF MEANS BY CHILDCARE SUBSIDY
ranksum kids, by(childcare)
tab childcare,sum(kids)
restore

tab1 paid_work fin retire gender partner partner_gender abortion

*SETTING UP PANEL DATA
sort id year
xtset id year

*POISSON REGRESSION - DEPENDENT VARIABLE:KIDS, REGRESSOR - PAID_WORK
xtpoisson kids paid_work, re vce(robust)
mfx

*TEST FOR OVERDISPERSION
predict yhat_poisson
quietly generate ystar=((kids-yhat_poisson)^2-kids)/yhat_poisson
sum ystar
reg ystar yhat_poisson,nocons

*RUNNING FIXED EFFECTS AND RANDOM EFFECTS REGRESSION ON PANEL DATA
xtreg kids paid_work i.year, fe cluster(id)
xtreg kids paid_work i.year, re cluster(id)


**********************************END***********************************



