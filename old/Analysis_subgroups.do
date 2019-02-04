clear
use full_plus

drop if total < 5000

rename md_earn_wne_p10 earnings


preserve
drop if price == .

egen p25 = pctile(price), p(25)
egen p75 = pctile(price), p(75)


gen comb_high = comb if price > p75
gen comb_low = comb if price < p25


collapse (sum) total comb_high comb_low, by(year)

gen top_quartile = (comb_high * 1000)/total
gen bottom_quartile = (comb_low * 1000)/total

line top_quartile bottom_quartile year, title("Reports of Sexual Assault by Avg. Cost of Attendance") ///
	subtitle("Schools with >10,000 enrolled students, per 1000 Students Enrolled") ///
	legend(order())
	
graph export costofattendance.png, replace
	
restore



preserve

drop if per_white == .
egen p25 = pctile(per_white), p(25)
egen p75 = pctile(per_white), p(75)

gen combh = comb if per_white > p75
gen combl = comb if per_white < p25

collapse (sum) total combh combl, by(year)

gen top_quartile_white = (combh * 1000)/total
gen bottom_quartile_white = (combl * 1000)/total

line top_quartile_white bottom_quartile_white year, title("Reports of Sexual Assault by Racial Makeup") ///
	subtitle("Schools with >10,000 enrolled students, per 1000 Students Enrolled") ///
	legend(order())
	
graph export white_nonwhite.png, replace
	
restore


preserve

replace sat_avg = "" if sat_avg == "NULL"
destring sat_avg, replace

drop if sat_avg == .
egen p25 = pctile(sat_avg), p(25)
egen p75 = pctile(sat_avg), p(75)

gen combh = comb if sat_avg > p75
gen combl = comb if sat_avg < p25

collapse (sum) total combh combl, by(year)

gen top_quartile_sat = (combh * 1000)/total
gen bottom_quartile_sat = (combl * 1000)/total

line top_quartile_sat bottom_quartile_sat year, title("Reports of Sexual Assault by Average SAT Score") ///
	subtitle("Schools with >10,000 enrolled students, per 1000 Students Enrolled") ///
	legend(order())
	
graph export satscore.png, replace
	
restore


preserve

rename upgrntp pell

drop if pell == .
egen p25 = pctile(pell), p(25)
egen p75 = pctile(pell), p(75)

gen combh = comb if pell > p75
gen combl = comb if pell < p25

collapse (sum) total combh combl, by(year)

gen top_quartile_pell = (combh * 1000)/total
gen bottom_quartile_pell = (combl * 1000)/total

line top_quartile_pell bottom_quartile_pell year, title("Reports of Sexual Assault by Pell Grant Award Rate") ///
	subtitle("Schools with >10,000 enrolled students, per 1000 Students Enrolled") ///
	legend(order())
	
graph export pellgrant.png, replace
	
restore


preserve

rename upgrntp pell

drop if pell == .
egen p75 = pctile(per_black), p(75)
egen w75 = pctile(per_white), p(75)
egen h75 = pctile(per_hisp), p(75)

gen combb = comb if per_black > p75
gen combw = comb if per_white > w75
gen combh = comb if per_hisp > h75


collapse (sum) total combh combb combw , by(year)

gen top_quartile_black = (combb * 1000)/total
gen top_quartile_white = (combw * 1000)/total
gen top_quartile_hispanic = (combh * 1000)/total

line top_quartile_black top_quartile_white top_quartile_hispanic year, title("Reports of Sexual Assault by Racial Makeup") ///
	subtitle("Schools with >10,000 enrolled students, per 1000 Students Enrolled") ///
	legend(order())
	
graph export white_black_hisp.png, replace
	
restore

preserve

drop if per_dem == .
drop if per_gop == .

egen d75 = pctile(per_dem), p(75)
egen g75 = pctile(per_gop), p(75)

gen combd = comb if per_dem > d75
gen combg = comb if per_gop > g75


collapse (sum) total combd combg , by(year)

gen top_quartile_dem = (combd * 1000)/total
gen top_quartile_gop = (combg * 1000)/total

line top_quartile_dem top_quartile_gop year, title("Reports of Sexual Assault by Votes in 2016 Election") ///
	subtitle("Schools with >10,000 enrolled students, per 1000 Students Enrolled") ///
	legend(order())
	
graph export votes.png, replace
	
restore


preserve

replace earnings = "" if earnings == "NULL"
destring earnings, replace
drop if earnings == .

egen p75 = pctile(earnings), p(75)
egen p25 = pctile(earnings), p(25)

gen combd = comb if earnings > p75
gen combg = comb if earnings < p25


collapse (sum) total combd combg , by(year)

gen top_quartile_earnings = (combd * 1000)/total
gen top_quartile_earnings = (combg * 1000)/total

line top_quartile_dem top_quartile_gop year, title("Reports of Sexual Assault by Med. Earnings 10y After College") ///
	subtitle("Schools with >10,000 enrolled students, per 1000 Students Enrolled") ///
	legend(order())
	
graph export earnings.png, replace
	
restore
