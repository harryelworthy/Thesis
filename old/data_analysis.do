clear
use full

* Use only large schools, to avoid 0 issues etc - following Lindo et al. (2018)
drop if total < 10000

* I think this is a reasonable regression? tbd
encode school, gen(si)
xtset si year

replace percap = percap * 1000

xtreg percap after_2011 i.year, fe
xtreg percap after_2011 i.year if state == "CA", fe
xtreg percap after_2011 i.year if state == "TX", fe
xtreg percap after_2011 i.year if state == "NC", fe


* Graph totals
replace year = year + 2000

encode state, gen(sti)
collapse (sum) total comb, by(year sti)
gen stateper1000 = (comb * 1000)/total
xtset sti year
xtline stateper1000, overlay title("Reports of Sexual Assault by State") ///
	subtitle("Schools with >10,000 enrolled students, per 1000 Students Enrolled") ///
	legend(order())


/*
collapse (sum) total comb, by(year)
gen reports_per_1000 = (comb * 1000)/total
tsset year
tsline reports_per_1000, title("Reports of Sexual Assault per 1000 Students Enrolled") ///
	subtitle("Schools with >10,000 enrolled students")

*/
