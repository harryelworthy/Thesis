set graphics off

clear
use "clean/school_full"

* Use only large schools, to avoid 0 issues etc - following Lindo et al. (2018)
drop if total < 10000

* I think this is a reasonable regression? tbd
encode school, gen(si)
xtset si year

replace percap = percap * 1000

collapse (sum) total comb, by(year)
gen reports_per_1000 = (comb * 1000)/total
tsset year
tsline reports_per_1000, title("Reports of Sexual Assault per 1000 Students Enrolled") ///
	subtitle("Schools with >10,000 enrolled students")
	
graph export "figures/school_reports.eps", as(eps) replace


*** SAME COUNTY SCHOOLS POLICE REPORTS REGRESS

estimates clear

clear
use "clean/school_police_county_cross"

encode county, gen(ci)
xtset ci year

eststo: qui xtreg police_pc school_pc i.year, fe
/*
qui testparm*
estadd scalar p_value = r(p)
*/

esttab using "figures/county_school_police_reports.tex", se ar2 drop(*year*) replace


* SAME SCHOOL CASES REPORTS

estimates clear

clear
use "processed/school_full_cases"
gen year_op = year(date_op - 182)
//year_op = year_t + 1 if month(date_op) <7

g lead2 = (year == year_op - 2)
g lead1 = (year == year_op - 1)
g yof = (year == year_op)
g lag1 = (year == year_op + 1)
g lag2 = (year == year_op + 2)

xtset id year

eststo: qui xtreg percap lead2 lead1 yof lag1 lag2 i.year, fe
eststo: qui xtreg percap after_2011 i.year, fe
eststo: qui xtreg percap lead2 lead1 yof lag1 lag2 after_2011 i.year, fe

esttab using "figures/same_school_cases_reports.tex", se ar2 drop (*year*) replace


* SAME COUNTY SCHOOLS CASES REPORTS

estimates clear

clear
use "processed/county_other_schools_cases"

g school_pc = comb/total
* g police_pc = rape/population1

gen year_op = year(fd - 182)

gen after_2011 = 0
replace after_2011 = 1 if year > 2011
//year_op = year_t + 1 if month(date_op) <7

g lead2 = (year == year_op - 2)
g lead1 = (year == year_op - 1)
g yof = (year == year_op)
g lag1 = (year == year_op + 1)
g lag2 = (year == year_op + 2)

encode county, gen (cs)
xtset cs year

eststo: qui xtreg school_pc lead2 lead1 yof lag1 lag2 i.year, fe
eststo: qui xtreg school_pc lead2 lead1 yof lag1 lag2 after_2011 i.year, fe
eststo: qui xtreg school_pc after_2011 i.year, fe

esttab using "figures/same_county_schools_cases_reports.tex", se ar2 drop (*year*) replace


* SAME COUNTY POLICE CASES REPORTS

estimates clear

clear
use "processed/county_police_cases"

gen county_pc = rape/population1

gen after_2011 = 0
replace after_2011 = 1 if year > 2011

gen year_op = year(fd - 182)
//year_op = year_t + 1 if month(date_op) <7

g lead2 = (year == year_op - 2)
g lead1 = (year == year_op - 1)
g yof = (year == year_op)
g lag1 = (year == year_op + 1)
g lag2 = (year == year_op + 2)

encode county, gen (cs)
xtset cs year

eststo: qui xtreg county_pc lead2 lead1 yof lag1 lag2 i.year, fe
eststo: qui xtreg county_pc lead2 lead1 yof lag1 lag2 after_2011 i.year, fe
eststo: qui xtreg county_pc after_2011 i.year, fe

esttab using "figures/same_county_police_cases_reports.tex", se ar2 drop (*year*) replace 


**** TRENDS ALL CASES

clear
use "processed/trends_cases_lags"

summarize b_norm
summarize b_norm if lead2 == 1
summarize b_norm if lead1 == 1
summarize b_norm if casedate == 1
summarize b_norm if lag1 == 1
summarize b_norm if lag2 == 1

**** TRENDS FIRST CASES

clear
use "processed/trends_first_cases_lags"

summarize b_norm
summarize b_norm if lead2 == 1
summarize b_norm if lead1 == 1
summarize b_norm if casedate == 1
summarize b_norm if lag1 == 1
summarize b_norm if lag2 == 1



**** TRENDS REPORTS GRAPH

** NEED A BETTER ONE - MONTHLY? RELATIVE TO YEAR? SOMETHING

/*
clear
use "clean/weekly"
rename sundayofweek week

merge 1:1 week using "clean/combtrends"
		 
drop if _merge != 3

rename rape reports

egen min_r = min(reports)
egen max_r = max(reports)

gen r_normalized = (reports - min_r)*100/(max_r - min_r)

drop if b_norm > 100

egen min_t = min(b_norm)
egen max_t = max(b_norm)

gen t_normalized = (b_norm - min_t)*100/(max_t - min_t)

scatter r_normalized t_normalized week

*/


** TRENDS WITH POLICE REPORTS

clear
use "processed/trends_police_reports"


estimates clear

gen woy = week(week)
gen year = year(week)

eststo: qui reg reports b_norm i.year i.woy

eststo: qui reg reports b_norm bn_norm i.year i.woy

eststo: qui reg reports b_norm bn_norm lag1 lag2 n_lag1 n_lag2 i.year i.woy

test b_norm lag1 lag2 bn_norm n_lag1 n_lag2

esttab using "figures/trends_reports_with_lags_extra_terms.tex", se ar2 drop (*year* *woy*) replace



** TRENDS WITH REPORTS OF PREVIOUS EVENTS

clear
use "processed/trends_police_reports_plus"

drop reports
rename idtbeforeweek reports

estimates clear

gen woy = week(week)
gen year = year(week)

eststo: qui reg reports b_norm i.year i.woy

eststo: qui reg reports b_norm bn_norm i.year i.woy

eststo: qui reg reports b_norm bn_norm lag1 lag2 n_lag1 n_lag2 i.year i.woy

test b_norm lag1 lag2 bn_norm n_lag1 n_lag2

esttab using "figures/trends_reports_earlier_events.tex", se ar2 drop (*year* *woy*) replace

** DAILY TRENDS NEW WITH CASES

clear
use "processed/daily_cases_lags"

g tmp = dofc(date)

form tmp %td

drop date
g date = tmp
drop tmp


g saweb = value if ((term == "sexual assault") & (property == "web"))
g sanews = value if ((term == "sexual assault") & (property == "news"))
g rapeweb = value if ((term == "rape") & (property == "web"))
g rapenews = value if ((term == "rape") & (property == "news"))

estimates clear

gen woy = week(date)
gen year = year(date)

eststo: qui reg saweb casedate lag* lead* i.year i.woy date
eststo: qui reg sanews casedate lag* lead* i.year i.woy date
eststo: qui reg rapeweb casedate lag* lead* i.year i.woy date
eststo: qui reg rapenews casedate lag* lead* i.year i.woy date



esttab, se ar2 drop (*year* *woy* date) replace


** STATE TRENDS NEW WITH CASES

clear
use "processed/states_trends_cases_lags"

g tmp = dofc(date)

form tmp %td

drop date
g date = tmp
drop tmp


g saweb = value if ((term == "sexual assault") & (property == "web"))
g sanews = value if ((term == "sexual assault") & (property == "news"))
g rapeweb = value if ((term == "rape") & (property == "web"))
g rapenews = value if ((term == "rape") & (property == "news"))

estimates clear

encode state, gen(si)

gen woy = week(date)
gen year = year(date)


preserve
drop if saweb == .
xtset si date
eststo: qui xtreg saweb casedate lag* lead* i.year i.woy 
restore

preserve
drop if sanews == .
xtset si date
eststo: qui xtreg sanews casedate lag* lead* i.year i.woy 
restore

preserve
drop if rapeweb == .
xtset si date
eststo: qui xtreg rapeweb casedate lag* lead* i.year i.woy 
restore

preserve
drop if rapenews == .
xtset si date
eststo: qui xtreg rapenews casedate lag* lead* i.year i.woy 
restore

/*

eststo: qui xtreg saweb casedate lead* lag* i.year i.woy 
eststo: qui xtreg sanews casedate lead* lag* i.year i.woy 
eststo: qui xtreg rapeweb casedate lead* lag* i.year i.woy 
eststo: qui xtreg rapenews casedate lead* lag* i.year i.woy

*/

esttab, se ar2 drop (*year* *woy*) replace



