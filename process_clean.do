* 

clear
use "clean/school_full_plus"

tostring id, gen(tmp)
gen id6s = substr(tmp, 1, 6)
drop tmp

preserve
keep id6s state
collapse (firstnm) state, by (id6s)
save "processed/school_state_id6s", replace
restore

merge m:1 id6s using "clean/first_cases"

* drop if total < 5000

save "processed/school_full_cases", replace



****** CASES WITH STATES

clear
use "clean/all_cases"
merge m:1 id6s using "processed/school_state_id6s"
drop if _merge != 3
drop _merge
save "processed/all_cases_states", replace




************

clear
use "processed/school_full_cases"

drop if total < 5000

tostring countycd, gen(cstring)
rename state stabb
gen cfips1 = substr(cstring, 3, 3)

gen county = stabb + cfips1

egen fd = min(date_op), by(county)
form fd %td


preserve
collapse (firstnm) cfips1 stabb fd, by (county)

save "processed/county_cases", replace
restore


drop if ((fd == date_op) & (date_op != .))

collapse (sum) comb total /*rape population1*/ (firstnm) cfips1 stabb fd id city school, by (county year)

save "processed/county_other_schools_cases", replace

*********

clear
use "processed/school_full_cases"

drop if total < 5000

tostring countycd, gen(cstring)
rename state stabb
gen cfips1 = substr(cstring, 3, 3)
*destring state_nibrs, replace

rename rape rape_s

drop _merge
merge m:m stabb cfips1 year using "clean/police_yearly_xw"
drop if _merge != 3

/*
use full_plus
rename zip ziplong
drop rape
gen zip = substr(ziplong, 1, 5)
merge m:1 zip year using yearly_xw
drop if _merge != 3
*/

sort year school

gen county = stabb + cfips1


collapse (sum) comb total rape population1 (firstnm) id city school, by (county year)

g school_pc = comb/total
g police_pc = rape/population1



save "clean/school_police_county_cross", replace




clear
use "clean/police_yearly_xw"

gen county = stabb + cfips1

collapse (sum) rape population1 , by (county year)

merge m:1 county using  "processed/county_cases"

save "processed/county_police_cases", replace




***** ALL CASES 

clear
use "clean/all_cases"


gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op))
gen casedate = 1
keep week casedate

collapse (firstnm) casedate, by(week)

save "clean/casedate", replace


clear
use "clean/all_cases"

gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op)) - 7
gen lead1 = 1
keep week lead1
collapse (firstnm) lead1, by(week)
save "clean/caselead1", replace

clear
use "clean/all_cases"

gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op)) - 14
gen lead2 = 1
keep week lead2
collapse (firstnm) lead2, by(week)
save "clean/caselead2", replace

clear
use "clean/all_cases"

gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op)) + 7
gen lag1 = 1
keep week lag1
collapse (firstnm) lag1, by(week)
save "clean/caselag1", replace

clear
use "clean/all_cases"

gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op)) + 14
gen lag2 = 1
keep week lag2
collapse (firstnm) lag2, by(week)
save "clean/caselag2", replace

clear
use "clean/casedate"

merge 1:1 week using "clean/caselead1", nogen
merge 1:1 week using "clean/caselead2", nogen
merge 1:1 week using "clean/caselag1", nogen
merge 1:1 week using "clean/caselag2", nogen

save "clean/cases_with_lags", replace


clear
use "clean/b"
drop lag*
merge 1:1 week using "clean/cases_with_lags"
save "processed/trends_cases_lags", replace



***** FIRST CASES

clear
use "clean/first_cases"


gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op))
gen casedate = 1
keep week casedate

collapse (firstnm) casedate, by(week)

save "clean/f_casedate", replace


clear
use "clean/first_cases"
gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op)) - 7
gen lead1 = 1
keep week lead1
collapse (firstnm) lead1, by(week)
save "clean/f_caselead1", replace

clear
use "clean/first_cases"
gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op)) - 14
gen lead2 = 1
keep week lead2
collapse (firstnm) lead2, by(week)
save "clean/f_caselead2", replace

clear
use "clean/first_cases"
gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op)) + 7
gen lag1 = 1
keep week lag1
collapse (firstnm) lag1, by(week)
save "clean/f_caselag1", replace

clear
use "clean/first_cases"
gen week = cond(dow(date_op) == 0, date_op, date_op - dow(date_op)) + 14
gen lag2 = 1
keep week lag2
collapse (firstnm) lag2, by(week)
save "clean/f_caselag2", replace

clear
use "clean/f_casedate"
merge 1:1 week using "clean/f_caselead1", nogen
merge 1:1 week using "clean/f_caselead2", nogen
merge 1:1 week using "clean/f_caselag1", nogen
merge 1:1 week using "clean/f_caselag2", nogen

save "clean/f_cases_with_lags", replace


clear
use "clean/combtrends"
drop lag*
merge 1:1 week using "clean/f_cases_with_lags"
save "processed/trends_first_cases_lags", replace

*** TRENDS REPORTS TOGETHER

clear
use "clean/weekly"
rename sundayofweek week

merge 1:1 week using "clean/combtrends"
		 
drop if _merge != 3

rename rape reports

save "processed/trends_police_reports", replace



** TRENDS WITH POLICE REPORTS PLUS

clear
use "clean/weeklyplus"

rename sundayofweek week

merge 1:1 week using "clean/combtrends"
		 
drop if _merge != 3


rename rape reports

save "processed/trends_police_reports_plus", replace


*** WEEK BY STATE REPORTS AND TRENDS

clear
use "clean/police_week_by_state"
keep stabb sundayofweek rape*
rename stabb state
rename sundayofweek date
gen term = "sexual assault"
gen property = "web"

merge 1:1 term state date property using "clean/trends"
drop if _merge != 3

keep state date value rape*
form date %td

save "processed/trends_police_week_by_state"



clear
use "clean/police_week_by_state_plus"
keep stabb sundayofweek rape* reports_pre
rename stabb state
rename sundayofweek date
gen term = "sexual assault"
gen property = "web"

merge 1:1 term state date property using "clean/trends"
drop if _merge != 3

keep state date value reports_pre
form date %td

save "processed/trends_police_week_by_state_plus"



*** DAILY REPORTS AND TRENDS

clear
use "clean/police_daily"
keep sundayofweek rape*
rename sundayofweek date
gen term = "sexual assault"
gen property = "web"

merge 1:1 term state date property using "clean/trends"
drop if _merge != 3

keep date value rape*
form date %td

save "processed/trends_police_daily"



clear
use "clean/police_daily"
keep sundayofweek rape* reports_pre
rename sundayofweek date
gen term = "sexual assault"
gen property = "web"

merge 1:1 term state date property using "clean/trends"
drop if _merge != 3

keep date value reports_pre
form date %td

save "processed/trends_police_daily"





