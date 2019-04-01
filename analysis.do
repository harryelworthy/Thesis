set graphics off
set scheme plotplain

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
	subtitle("Schools with >10,000 enrolled students") xline(2011)
	
graph export "figures/school_reports.eps", as(eps) replace




clear
use "clean/police_yearly"

collapse (sum) rape population1, by(year)
g reports_per_1000 = (rape*1000)/population1

tsset year
tsline reports_per_1000, title("Reports to Police of Sexual Assault per 1000 People") ///
	subtitle("In covered districs, per year")
	
graph export "figures/police_yearly_reports.eps", as(eps) replace
	


*** SAME COUNTY SCHOOLS POLICE REPORTS REGRESS

estimates clear

clear
use "clean/school_police_county_cross"

encode county, gen(ci)
xtset ci year


eststo: qui xtreg police_pc school_pc i.year, fe
test school_pc
/*
qui testparm*
estadd scalar p_value = r(p)
*/

esttab using "figures/county_school_police_reports.tex", se ar2 drop(*year*) replace


* SAME SCHOOL CASES REPORTS

estimates clear

clear
use "processed/schools_cases_lags"


xtset id year

eststo: qui xtreg percap lead5 lead4 lead3 lead2 lead1 casedate lag1 lag2 lag3 lag4 lag5 i.year, fe
eststo: qui xtreg percap after_2011 i.year, fe
eststo: qui xtreg percap lead5 lead4 lead3 lead2 lead1 casedate lag1 lag2 lag3 lag4 lag5 after_2011 i.year, fe

esttab using "figures/same_school_cases_reports.tex", se ar2 drop (*year*) replace

coefplot(est1), vertical drop(*year* _cons) yline(0) title("Impact with lags of an Investigation on Reports at Schools")
graph export "figures/cases_schools_reports_lags.eps", as(eps) replace

estimates clear

clear
use "processed/schools_cases_lags_new"


xtset id year

eststo: qui xtreg percap lead* casedate* lag* i.year, fe

esttab using "figures/same_school_cases_reports_numbered.tex", se ar2 drop (*year* lead* lag* casedate6 casedate5 casedate4) replace

coefplot(est1), vertical keep(casedate0 casedate1 casedate2 casedate3) yline(0) title("Impact of each Investigation on Reports at Schools")
graph export "figures/cases_school_reports_numbered.eps", as(eps) replace

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
* eststo: qui xtreg school_pc lead2 lead1 yof lag1 lag2 after_2011 i.year, fe
* eststo: qui xtreg school_pc after_2011 i.year, fe

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
* eststo: qui xtreg county_pc lead2 lead1 yof lag1 lag2 after_2011 i.year, fe
* eststo: qui xtreg county_pc after_2011 i.year, fe

esttab using "figures/same_county_police_cases_reports.tex", se ar2 drop (*year*) replace 



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
use "processed/daily_trends_cases_lags"

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
gen dow = dow(date)

eststo: qui reg saweb lead7 lead6 lead5 lead4 lead3 lead2 lead1 casedate lag* i.year i.woy i.dow
* eststo: qui reg sanews casedate lag* lead* i.year i.woy i.dow 
* eststo: qui reg rapeweb casedate lag* lead* i.year i.woy i.dow 
* eststo: qui reg rapenews casedate lag* lead* i.year i.woy i.dow 

coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("National GTrends before/after Investigation, Daily")
graph export "figures/national_trend_cases.eps", as(eps) replace
* esttab, se ar2 drop (*year* *woy* *dow* date) replace


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
eststo: qui xtreg saweb lead7 lead6 lead5 lead4 lead3 lead2 lead1 casedate lag* lead* i.year i.woy 
restore

/*
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

*/

*eststo: qui xtreg saweb casedate lead* lag* i.year i.woy 

/*
eststo: qui xtreg sanews casedate lead* lag* i.year i.woy 
eststo: qui xtreg rapeweb casedate lead* lag* i.year i.woy 
eststo: qui xtreg rapenews casedate lead* lag* i.year i.woy

*/

coefplot(est1), vertical drop(*year* *woy* _cons) yline(0) title("State GTrends before/after Investigation, Weeks")
graph export "figures/state_trend_cases.eps", as(eps) replace

* esttab, se ar2 drop (*year* *woy*) replace




*****************************************************
***** TRENDS LAGS 
*****************************************************

estimates clear

clear
use "processed/trends_police_daily"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = trend[_n-`i']
	g lead`i' = trend[_n+`i']
}

eststo: qui reg rape  lag7 lag6 lag5 lag4 lag3 lag2 lag1 trend lead* i.year i.woy i.dow


coefplot(est1), vertical drop(*year* *woy* *dow _cons) title("Reports to Police vs. Trends, Daily") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Estimated effect of Google Trends on Reports") yline(0)
graph export "figures/police_trend_daily.eps", as(eps) replace

estimates clear

**** LOG TREND

estimates clear
clear
use "processed/trends_police_daily"

replace trend = log(trend)

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = trend[_n-`i']
	g lead`i' = trend[_n+`i']
}

eststo: qui reg rape  lag7 lag6 lag5 lag4 lag3 lag2 lag1 trend lead* i.year i.woy i.dow


coefplot(est1), vertical drop(*year* *woy* *dow _cons) title("Reports to Police vs. Trends, Daily") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Estimated effect of Google Trends on Reports") yline(0)
graph export "figures/police_trend_daily_logtrend.eps", as(eps) replace


**** LOG BOTH

estimates clear
clear
use "processed/trends_police_daily"

replace trend = log(trend)
g log_rape = log(rape)

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = trend[_n-`i']
	g lead`i' = trend[_n+`i']
}

eststo: qui reg log_rape  lag7 lag6 lag5 lag4 lag3 lag2 lag1 trend lead* i.year i.woy i.dow


coefplot(est1), vertical drop(*year* *woy* *dow _cons) title("Reports to Police vs. Trends, Daily") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Estimated effect of Google Trends on Reports") yline(0)
graph export "figures/police_trend_daily_logboth.eps", as(eps) replace


clear
use "processed/trends_police_daily_plus"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = trend[_n-`i']
	g lead`i' = trend[_n+`i']
}

eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 trend lag* i.year i.woy i.dow
coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("Reports to Police vs. Trends, Daily")


clear
use "processed/trends_police_daily_idt"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = trend[_n-`i']
	g lead`i' = trend[_n+`i']
}

eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 trend lag* i.year i.woy i.dow


clear
use "processed/trends_police_daily_idt_plus"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = trend[_n-`i']
	g lead`i' = trend[_n+`i']
}

eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 trend lag* i.year i.woy i.dow


esttab using "figures/police_trend_daily.tex", se ar2 drop(*year* *woy* *dow*) replace




estimates clear

clear
use "processed/trends_police_week_by_state"

sort state date 

forv i = 1(1)7{
	by state: g lag`i' = trend[_n-`i']
	by state: g lead`i' = trend[_n+`i']
}

encode state, gen(si)
xtset date si
g woy = week(date)
g year = year(date)

eststo: qui xtreg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 trend lag* i.year i.woy, fe


coefplot(est1), vertical drop(*year* *woy* _cons) yline(0) title("Reports to Police vs. Trends, Week by State")
graph export "figures/police_trend_week_by_state.eps", as(eps) replace


clear
use "processed/trends_police_week_by_state_plus"

sort state date 

forv i = 1(1)7{
	by state: g lag`i' = trend[_n-`i']
	by state: g lead`i' = trend[_n+`i']
}

encode state, gen(si)
xtset date si
g woy = week(date)
g year = year(date)

eststo: qui xtreg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 trend lag* i.year i.woy, fe


esttab using "figures/police_trend_week_by_state.tex", se ar2 drop(*year* *woy*) replace

clear 
clear matrix
clear mata
set maxvar 10000
set matsize 10000
set emptycells drop

estimates clear
clear
use "processed/trends_police_daily_by_state"

sort state date 

forv i = 1(1)7{
	by state: g lag`i' = trend[_n-`i']
	by state: g lead`i' = trend[_n+`i']
}

encode state, gen(si)
xtset date si
g woy = week(date)
g year = year(date)
g dow = dow(date)



*eststo: qui xtreg rape  lead2 lead1 trend lag1 lag2 i.date, fe

* lead7 lead6 lead5 lead4 lead3

*esttab /*using "figures/police_trend_daily_by_state.tex"*/, se ar2 keep(lead2 lead1 trend lag1 lag2 ) replace





**************************************************
*** EVENT STUDY HIGH TREND
**************************************************

estimates clear

clear
use "processed/trends_police_daily"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 50(25)150{
	g dateofhigh = 0
	replace dateofhigh = 1 if (trend >= `i')
	forv j = 1(1)7{
		g lag`j' = dateofhigh[_n-`j']
		g lead`j' = dateofhigh[_n+`j']
	}
	eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 dateofhigh lag* i.year i.woy i.dow
	drop dateofhigh lag* lead*
}


esttab using "figures/police_trend_daily_ES.tex", se ar2 drop(*year* *woy* *dow*) replace


estimates clear

clear
use "processed/trends_police_daily_idt"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 50(25)150{
	g dateofhigh = 0
	replace dateofhigh = 1 if (trend >= `i')
	forv j = 1(1)7{
		g lag`j' = dateofhigh[_n-`j']
		g lead`j' = dateofhigh[_n+`j']
	}
	eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 dateofhigh lag* i.year i.woy i.dow
	drop dateofhigh lag* lead*
}


esttab using "figures/police_trend_daily_idt_ES.tex", se ar2 drop(*year* *woy* *dow*) replace




estimates clear

clear
use "processed/trends_police_week_by_state"


g woy = week(date)
g year = year(date)
encode state, gen(si)
xtset date si

forv i = 50(25)150{
	sort state date 
	
	g dateofhigh = 0
	replace dateofhigh = 1 if (trend >= `i')
	forv j = 1(1)7{
		by state: g lag`j' = dateofhigh[_n-`j']
		by state: g lead`j' = dateofhigh[_n+`j']
	}
	eststo: qui xtreg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 dateofhigh lag* i.year i.woy, fe
	drop dateofhigh lag* lead*
}


esttab using "figures/police_trend_wbs_ES.tex", se ar2 drop(*year* *woy*) replace



*****************************
****** AGES AND RACES *******
*****************************



estimates clear

clear
use "processed/trends_police_daily"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = trend[_n-`i']
	g lead`i' = trend[_n+`i']
}

preserve

forv j = 10(10)60{
	loc k = `j' + 9
	rename lead1 lead1_`j'_to_`k'
	eststo: qui reg rape_victim_`j'_to_`k' lead7 lead6 lead5 lead4 lead3 lead2 lead1_`j'_to_`k' trend lag* i.year i.woy i.dow
}


coefplot(est*), vertical drop(*year* *woy* *dow lead7 lead6 lead5 lead4 lead3 lead2 trend lag* _cons) yline(0) title("Reports to Police vs. Trends, by Age Group")
graph export "figures/police_trend_daily_agegroup.eps", as(eps) replace

restore
preserve
estimates clear

rename lead1 lead1_wht
eststo: qui reg rape_vwht lead7 lead6 lead5 lead4 lead3 lead2 lead1_wht trend lag* i.year i.woy i.dow

rename lead1 lead1_blk
eststo: qui reg rape_vblk lead7 lead6 lead5 lead4 lead3 lead2 lead1_blk trend lag* i.year i.woy i.dow

rename lead1 lead1_oth
eststo: qui reg rape_voth lead7 lead6 lead5 lead4 lead3 lead2 lead1_oth trend lag* i.year i.woy i.dow

coefplot(est*), vertical drop(*year* *woy* *dow lead7 lead6 lead5 lead4 lead3 lead2 trend lag* _cons) yline(0) title("Reports to Police vs. Trends, by Race of Victim")
graph export "figures/police_trend_daily_race.eps", as(eps) replace

restore
estimates clear
drop rapenonalc
g rapenonalc = rape - rapealc

rename lead1 lead1_alc
eststo: qui reg rapealc lead7 lead6 lead5 lead4 lead3 lead2 lead1_alc trend lag* i.year i.woy i.dow

rename lead1 lead1_nonalc
eststo: qui reg rapenonalc lead7 lead6 lead5 lead4 lead3 lead2 lead1_nonalc trend lag* i.year i.woy i.dow

coefplot(est*), vertical drop(*year* *woy* *dow lead7 lead6 lead5 lead4 lead3 lead2 trend lag* _cons) yline(0) title("Reports to Police vs. Trends, Alcohol Involvement")
graph export "figures/police_trend_daily_alc.eps", as(eps) replace





**** WEINSTEIN
clear
use "/Users/harry/Google Drive/GDocuments/F18/Thesis/DATA/Final/clean/daily_trends.dta"
keep if (term == "sexual assault" & property == "web")
drop if date < date[3536]
drop if date > date[62]

tsset date

tsline value




**** EVENTS TRENDS

estimates clear
clear
use "processed/trends_events"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = event_date[_n-`i']
	g lead`i' = event_date[_n+`i']
}

eststo: qui reg value lead7 lead6 lead5 lead4 lead3 lead2 lead1 event_date lag* i.year i.woy i.dow
coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("Google Trends before and after High-Profile Events") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Relative Google Trend") yline(0)
graph export "figures/events_trend.eps", as(eps) replace

* W REPORTS

estimates clear
clear
use "processed/police_daily_events"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = event_date[_n-`i']
	g lead`i' = event_date[_n+`i']
}

eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 event_date lag* i.year i.woy i.dow, robust
coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("Reports to Police  before and after High-Profile Events") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Reports to Police") yline(0)
graph export "figures/events_police.eps", as(eps) replace

*** ONLY ALLEGATIONS

estimates clear
clear
use "processed/police_daily_events"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = allegation[_n-`i']
	g lead`i' = allegation[_n+`i']
}

eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 allegation lag* i.year i.woy i.dow
coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("Reports to Police  before and after High-Profile Allegations") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Reports to Police") yline(0)
graph export "figures/events_police_allegations.eps", as(eps) replace

*** ONLY BIG ALLEGATIONS

estimates clear
clear
use "processed/police_daily_events"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = big_allegation[_n-`i']
	g lead`i' = big_allegation[_n+`i']
}

eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 big_allegation lag* i.year i.woy i.dow
coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("Reports to Police  before and after 'Big Allegations'") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Reports to Police") yline(0)
graph export "figures/events_police_big.eps", as(eps) replace



** IDT EVENTS


estimates clear
clear
use "processed/police_daily_events_idt"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = event_date[_n-`i']
	g lead`i' = event_date[_n+`i']
}

eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 event_date lag* i.year i.woy i.dow, robust
coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("Reports to Police vs. Trends, Daily") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Reports to Police") yline(0)

esttab, se ar2 drop(*year* *dow* *woy* )

** PLUS EVENTS


estimates clear
clear
use "processed/police_daily_events_plus"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)7{
	g lag`i' = event_date[_n-`i']
	g lead`i' = event_date[_n+`i']
}

eststo: qui reg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 event_date lag* i.year i.woy i.dow, robust
coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("Reports to Police vs. Trends, Daily") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Reports to Police") yline(0)
esttab, se ar2 drop(*year* *dow* *woy* )


*** BIN NOT WORKING

/*

estimates clear
clear
use "processed/police_daily_events"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

loc bin_size = 2
loc num_lags = 7

forv i = 1(1)`num_lags'{
	loc mult = `bin_size'*`i'
	g lag`i' = 0
	g lead`i' = 0
	forv j = 0(1)`bin_size'-1{
		replace lag`i' = lag`i' + event_date[_n-`j'-`mult'-`bin_size']
		replace lead`i' = lead`i' + event_date[_n+`j'+`mult']
	}
}

forv j = 1(1)`bin_size'{
	replace event_date = event_date + event_date[_n-`j']
}

eststo: qui reg rape event_date lag* i.year i.woy i.dow, robust
coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("Reports to Police vs. Trends, Daily")
*/


*** BIN WORKING

estimates clear
clear
use "processed/police_daily_events"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)
g my = mofd(date)
g wy = wofd(date)
g twy = cond(mod(wy, 2) == 0, wy, wy - 1)

forv i = 1(1)14{
	g lag`i' = event_date[_n-`i']
	g lead`i' = event_date[_n+`i']
}

gen lead_bin4 = (lead12 + lead11 + lead10)/3
gen lead_bin3 = (lead9 + lead8 + lead7)/3
gen lead_bin2 = (lead6 + lead5 + lead4)/3
gen lead_bin1 = (lead3 + lead2 + lead1)/3
gen event_bin = (event_date + lag1 + lag2)/3
gen lag_bin1 = (lag3 + lag4 + lag5)/3
gen lag_bin2 = (lag6 + lag7 + lag8)/3
gen lag_bin3 = (lag9 + lag10 + lag11)/3
gen lag_bin4 = (lag12 + lag13 + lag14)/3

*eststo: qui reg rape lead_bin4 lead_bin3 lead_bin2 lead_bin1 event_bin lag_bin* i.year i.woy
*eststo: qui reg rape lead_bin4 lead_bin3 lead_bin2 lead_bin1 event_bin lag_bin* i.my
*eststo: qui reg rape lead_bin4 lead_bin3 lead_bin2 lead_bin1 event_bin lag_bin* i.wy
*eststo: qui reg rape lead_bin4 lead_bin3 lead_bin2 lead_bin1 event_bin lag_bin* i.twy
test event_bin
coefplot(est1), vertical drop(*year* *woy* *dow *my* *wy* _cons) yline(0) title("Reports to Police  before and after High-Profile Events, Binned") xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" 5 "2") xtitle("3 day bins surrounding event, with t=0 being event date and two lags") ytitle("Reports to Police") yline(0)
graph export "figures/events_police_binned.eps", as(eps) replace

esttab, se ar2 drop(*year* *dow* *woy* *my* )


*** ALLEGATIONS

estimates clear
clear
use "processed/police_daily_events"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)

forv i = 1(1)8{
	g lag`i' = allegation[_n-`i']
	g lead`i' = allegation[_n+`i']
}

gen lead_bin2 = (lead6 + lead5 + lead4)/3
gen lead_bin1 = (lead3 + lead2 + lead1)/3
gen event_bin = (allegation + lag1 + lag2)/3
gen lag_bin1 = (lag3 + lag4 + lag5)/3
gen lag_bin2 = (lag6 + lag7 + lag8)/3

eststo: qui reg rape lead_bin2 lead_bin1 event_bin lag_bin* i.year i.woy i.dow
test event_bin
coefplot(est1), vertical drop(*year* *woy* *dow _cons) yline(0) title("Reports to Police vs. Trends, Daily")
graph export "figures/events_police_binned_alle.eps", as(eps) replace
esttab, se ar2 drop(*year* *dow* *woy* )


*** BIG ALLEGATIONS

estimates clear
clear
use "processed/police_daily_events"

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)
g wy = wofd(date)


forv i = 1(1)8{
	g lag`i' = big_allegation[_n-`i']
	g lead`i' = big_allegation[_n+`i']
}


gen lead_bin2 = (lead6 + lead5 + lead4)/3
gen lead_bin1 = (lead3 + lead2 + lead1)/3
gen event_bin = (big_allegation + lag1 + lag2)/3
gen lag_bin1 = (lag3 + lag4 + lag5)/3
gen lag_bin2 = (lag6 + lag7 + lag8)/3
eststo: qui reg rape lead_bin2 lead_bin1 event_bin lag_bin* i.year i.woy i.dow
*eststo: qui reg rape lead_bin2 lead_bin1 event_bin lag_bin* i.wy

test event_bin
coefplot(est1), vertical drop(*year* *woy* *wy* *dow _cons) yline(0) title("Reports to Police vs. Trends, Daily")
graph export "figures/events_police_binned_big.eps", as(eps) replace
esttab, se ar2 drop(*year* *dow* *woy* *wy*)




*** INSTRUMENT


estimates clear
clear
use "processed/trends_events"

merge 1:1 date using "processed/police_daily_events"

rename value trend

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)
g my = mofd(date)
g wy = wofd(date)
g twy = cond(mod(wy, 2) == 0, wy, wy - 1)

forv i = 1(1)8{
	g elag`i' = event_date[_n-`i']
	g elead`i' = event_date[_n+`i']
}

forv i = 1(1)7{
	g lag`i' = trend[_n-`i']
	g lead`i' = trend[_n+`i']
}

gen lead_bin2 = elead6 + elead5 + elead4
gen lead_bin1 = elead3 + elead2 + elead1 
gen event_bin = event_date + elag1 + elag2
gen lag_bin1 = elag3 + elag4 + elag5
gen lag_bin2 = elag6 + elag7 + elag8

ivregress 2sls rape i.year i.woy (trend = event_bin)


**** DIFFERING INSTRUMENT

estimates clear
clear
use "processed/trends_events"

merge 1:1 date using "processed/police_daily_events"

rename value trend
g log_trend = log(trend)
g log_reports = log(rape)

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)
g my = mofd(date)
g wy = wofd(date)
g twy = cond(mod(wy, 2) == 0, wy, wy - 1)

forv i = 1(1)8{
	g elag`i' = event_date[_n-`i']
	g elead`i' = event_date[_n+`i']
}

forv i = 1(1)8{
	g e2lag`i' = name[_n-`i']
	g e2lead`i' = name[_n+`i']
}


forv i = 1(1)7{
	g lag`i' = trend[_n-`i']
	g lead`i' = trend[_n+`i']
}

gen lead_bin2 = elead6 + elead5 + elead4
gen lead_bin1 = elead3 + elead2 + elead1 
gen event_bin = event_date + elag1 + elag2
gen lag_bin1 = elag3 + elag4 + elag5
gen lag_bin2 = elag6 + elag7 + elag8

g event_bin2 = name + e2lag1 + e2lag2
encode event_bin2, gen(ei)
replace ei = 0 if ei == .

eststo: qui ivregress 2sls log_reports i.year i.woy i.dow (log_trend = event_bin)
eststo: qui ivregress 2sls log_reports i.my i.dow (log_trend = event_bin)
eststo: qui ivregress 2sls log_reports i.wy i.dow (log_trend = event_bin)
eststo: qui ivregress 2sls log_reports i.year i.woy (log_trend = i.ei)
eststo: qui ivregress 2sls log_reports i.my (log_trend = i.ei)
eststo: qui ivregress 2sls log_reports i.wy (log_trend = i.ei)

esttab, se ar2 drop(*year* *woy* *wy* *my* *dow*)




*** T9 Cases event study by state by day
* SIGNIF IF NO FE? ESPECIALLY IF log_rape? UNSURE

clear
use "processed/police_daily_by_state_cases"

rename rdt date
rename stabb state

estimates clear

g log_rape = log(rape)

encode state, gen(si)

gen woy = week(date)
gen year = year(date)
gen dow = dow(date)

sort state date

forv j = 1(1)7{
	by state: g lag`j' = event_date[_n-`j']
	by state: g lead`j' = event_date[_n+`j']
}

xtset si date
eststo: qui xtreg rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 event_date lag* i.year i.woy i.dow, fe

coefplot(est*), vertical drop(*year* *woy* *dow* _cons) yline(0) title("Reports before/after T9 Investigation, Daily, Within State") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Reports to Police") yline(0)
graph export "figures/police_state_cases.eps", as(eps) replace


*** T9 Cases event study by day Nationally

clear
use "processed/police_daily_cases"

rename rdt date

estimates clear

g log_rape = log(rape)

gen woy = week(date)
gen year = year(date)
gen dow = dow(date)

forv j = 1(1)7{
	g lag`j' = event_date[_n-`j']
	g lead`j' = event_date[_n+`j']
}

eststo: qui reg log_rape lead7 lead6 lead5 lead4 lead3 lead2 lead1 event_date lag* i.year i.woy i.dow

coefplot(est*), vertical drop(*year* *woy* *dow* _cons) yline(0) title("Reports before/after T9 Investigation, Daily, Nationally") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Reports to Police") yline(0)
graph export "figures/police_national_cases.eps", as(eps) replace


*** T9 Cases instrumental

clear
use "processed/police_daily_cases"
drop _merge

rename rdt date
rename event_date case_date

merge 1:1 date using "processed/trends_events"
rename value trend

gen woy = week(date)
gen year = year(date)
gen dow = dow(date)


ivregress 2sls rape i.year i.woy i.dow (trend = case_date) 



*** TABLE OF HP EVENTS
/*
clear
use "clean/high_profile_events"
drop notes event_date
order date name allegation big_allegations
dataout, save("figures/hpevents") tex replace
*/



use "/Users/harry/Google Drive/GDocuments/F18/Thesis/DATA/Final/clean/idt_analysis.dta", clear
drop if days_from_event < -60
g new_d = days_from_event + 100
regress rape i.new_d i.placebo
margins new_d, over(placebo)
marginsplot
g woy = week(idt)
g dow = dow(idt)
g year = year(idt)
qui regress rape i.new_d i.placebo i.woy i.dow i.year
qui margins new_d, over(placebo)
marginsplot
graph export "figures/idt_analysis.eps", as(eps) replace

use "/Users/harry/Google Drive/GDocuments/F18/Thesis/DATA/Final/clean/idt_analysis.dta", clear
drop if days_from_event < -60
collapse (mean) rape, by(days_from_event placebo)
g rape_event = rape if placebo == 0
g rape_plac = rape if placebo == 1
line rape_plac rape_event days_from_event
graph export "figures/idt_analysis_2.eps", as(eps) replace




*** OUTPUT A BUNCH OF TABLES TO COMBINE INTO ONE. Overall effect, then by subgroups, for TS, Instrumental 1 and instrumental 2 specs


estimates clear
clear
use "processed/trends_events"
merge 1:1 date using "processed/police_daily_events"
rename value trend

g log_trend = log(trend)
g log_reports = log(rape)

tsset date
g dow = dow(date)
g woy = week(date)
g year = year(date)
g my = mofd(date)
g wy = wofd(date)
g twy = cond(mod(wy, 2) == 0, wy, wy - 1)

forv i = 1(1)8{
	g elag`i' = event_date[_n-`i']
	g elead`i' = event_date[_n+`i']
}

forv i = 1(1)8{
	g e2lag`i' = name[_n-`i']
	g e2lead`i' = name[_n+`i']
}

gen event_bin = event_date + elag1 + elag2
g event_bin2 = name + e2lag1 + e2lag2
encode event_bin2, gen(ei)
replace ei = 0 if ei == .

* LAGS FOR TREND
forv i = 1(1)7{
	g lag`i' = log_trend[_n-`i']
	g lead`i' = log_trend[_n+`i']
}
rename log_trend ev_d
rename lead1 log_trend

* OVERALL EFFECT

* First Form
eststo: qui reg log_reports lag7 lag6 lag5 lag4 lag3 lag2 lag1 ev_d log_trend lead* i.year i.woy i.dow
coefplot(est1), vertical drop(*year* *woy* *dow _cons) title("Reports to Police vs. Trends, Daily") xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7") xtitle("Days surrounding event at t=0") ytitle("Estimated effect of Google Trends on Reports") yline(0)
graph export "figures/police_trend_daily_logboth.eps", as(eps) replace
estimates clear
* Drop leads for actual regression
eststo: qui reg log_reports ev_d log_trend lead* i.year i.woy i.dow
preserve
rename log_trend lead1
rename ev_d log_trend

* Second Form
eststo: qui ivregress 2sls log_reports i.wy i.dow (log_trend = event_bin)

* Third form
eststo: qui ivregress 2sls log_reports i.wy (log_trend = i.ei)
restore

esttab using "figures/tbc_1.tex", se ar2 drop(*wy* *dow* _cons *ev_d* *lead* *year* *woy* *dow*) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

* AGE GROUPS


forv j = 10(10)60{
	loc k = `j' + 9
	g log_rep_`j'_to_`k' = log(rape_victim_`j'_to_`k')
	preserve
	estimates clear
	rename log_trend log_trend_`j'_to_`k'
	eststo: qui reg log_rep_`j'_to_`k' ev_d log_trend_`j'_to_`k' lead* i.year i.woy i.dow
	restore
	preserve
	rename log_trend lead1
	rename ev_d log_trend_`j'_to_`k'
	eststo: qui ivregress 2sls log_rep_`j'_to_`k' i.wy i.dow (log_trend_`j'_to_`k' = event_bin)
	eststo: qui ivregress 2sls log_rep_`j'_to_`k' i.wy (log_trend_`j'_to_`k' = i.ei)
	restore
	esttab using figures/tbc_`j'_`k'.tex, se ar2 drop(*wy* *dow* _cons *ev_d* *lead* *year* *woy* *dow*) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
}

* Races
estimates clear
g log_rep_white = log(rape_vwht)
preserve
rename log_trend log_trend_white
eststo: qui reg log_rep_white ev_d log_trend_white lead* i.year i.woy i.dow
restore
preserve
rename log_trend lead1
rename ev_d log_trend_white
eststo: qui ivregress 2sls log_rep_white i.wy i.dow (log_trend_white = event_bin)
eststo: qui ivregress 2sls log_rep_white i.wy (log_trend_white = i.ei)
restore
esttab using "figures/tbc_white.tex", se ar2 drop(*wy* *dow* _cons *ev_d* *lead* *year* *woy* *dow*) replace
	
estimates clear
g log_rep_black = log(rape_vblk)
preserve
rename log_trend log_trend_black
eststo: qui reg log_rep_black ev_d log_trend_black lead* i.year i.woy i.dow
restore
preserve
rename log_trend lead1
rename ev_d log_trend_black
eststo: qui ivregress 2sls log_rep_black i.wy i.dow (log_trend_black = event_bin)
eststo: qui ivregress 2sls log_rep_black i.wy (log_trend_black = i.ei)
restore
esttab using "figures/tbc_black.tex", se ar2 drop(*wy* *dow* _cons *ev_d* *lead* *year* *woy* *dow*) replace

estimates clear
g log_rep_other = log(rape_voth)
preserve
rename log_trend log_trend_other
eststo: qui reg log_rep_other ev_d log_trend_other lead* i.year i.woy i.dow
restore
preserve
rename log_trend lead1
rename ev_d log_trend_other
eststo: qui ivregress 2sls log_rep_other i.wy i.dow (log_trend_other = event_bin)
eststo: qui ivregress 2sls log_rep_other i.wy (log_trend_other = i.ei)
restore
esttab using "figures/tbc_other.tex", se ar2 drop(*wy* *dow* _cons *ev_d* *lead* *year* *woy* *dow*) replace

* Alc*

drop rapenonalc
g rapenonalc = rape - rapealc
g log_rep_non_alc = log(rapenonalc)

estimates clear
g log_rep_alc = log(rapealc)
preserve
rename log_trend log_trend_alc
eststo: qui reg log_rep_alc ev_d log_trend_alc lead* i.year i.woy i.dow
restore
preserve
rename log_trend lead1
rename ev_d log_trend_alc
eststo: qui ivregress 2sls log_rep_alc i.wy i.dow (log_trend_alc = event_bin)
eststo: qui ivregress 2sls log_rep_alc i.wy (log_trend_alc = i.ei)
esttab using "figures/tbc_alc.tex", se ar2 drop(*wy* *dow* _cons *ev_d* *lead* *year* *woy* *dow*) replace
restore

estimates clear
preserve
rename log_trend log_trend_non_alc
eststo: qui reg log_rep_non_alc ev_d log_trend_non_alc lead* i.year i.woy i.dow
restore
preserve
rename log_trend lead1
rename ev_d log_trend_non_alc
eststo: qui ivregress 2sls log_rep_non_alc i.wy i.dow (log_trend_non_alc = event_bin)
eststo: qui ivregress 2sls log_rep_non_alc i.wy (log_trend_non_alc = i.ei)
esttab using "figures/tbc_nonalc.tex", se ar2 drop(*wy* *dow* _cons *ev_d* *lead* *year* *woy* *dow*) replace
restore
