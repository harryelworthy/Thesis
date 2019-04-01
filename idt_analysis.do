


*This file reads in and organizes nibrs data for all years
* Data from: https://www.icpsr.umich.edu/icpsrweb/NACJD/search/studies?q=NIBRS&
* Extract Files
* AND from: https://www.openicpsr.org/openicpsr/project/100462/version/V3/view?path=/openicpsr/100462/fcr:versions/V3/Data-Construction/Data-Files/orischool.xls&type=file
clear all

clear
use "clean/high_profile_events"
levelsof date, local(dates_of_events)

clear
set obs 1
set seed 98034
local a = 18099
local b = 20877
generate dates = floor((20877 - 18099 + 1)*runiform() + 18099)
levelsof dates, local(dates_of_placebo)


clear

use "raw/out_allyears"

gen tmp = "0"
replace tmp = "1" if (datereport == "R")
drop datereport
rename tmp datereport

save "raw/out_allyears", replace


forv i = 2013(1)2016{
di "year: `i'"


  use "raw/`i'_raw"
  ren *, lower
  rename bh005 date_added
  rename bh006 date_nibrs
  rename bh007 city
  rename bh008 stabb
  rename bh009 pop_group
  rename bh012 agency_indic
  *keep only city police
  *keep if agency_indic==1


  rename bh019 pop1
  rename bh023 pop2
  rename bh027 pop3
  rename bh031 pop4
  destring pop1, replace



  *year specific

   rename bh035 pop5
   rename bh039 rep_indicator
   rename bh040 monthsreported
   rename bh042 rep_jan
   rename bh043 rep_feb
   rename bh044 rep_march
   rename bh045 rep_apr
   rename bh046 rep_may
   rename bh047 rep_june
   rename bh048 rep_july
   rename bh049 rep_aug
   rename bh050 rep_sep
   rename bh051 rep_oct
   rename bh052 rep_nov
   rename bh053 rep_dec
   rename bh054 cfips1
   rename bh055 cfips2
   rename bh056 cfips3
   rename bh057 cfips4
   rename bh058 cfips5

  rename incnum ino
  rename incdate idate
  destring idate, replace
  rename v1006 datereport
  rename v1007 ihour



  rename v20061 offensecode
  rename v20081 offusing1
  rename v20091 offusing2
  rename v20101 offusing3
  rename v20111 location
  rename v20171 weapon1
  rename v20181 weapon2
  rename v20191 weapon3v
  rename v40061 vseqno
  rename v40071 offense1
  rename v40081 offense2
  rename v40091 offense3
  rename v40101 offense4
  rename v40111 offense5
  rename v40121 offense6
  rename v40131 offense7
  rename v40141 offense8
  rename v40151 offense9
  rename v40161 offense10



  rename v40181 vage
    replace vage=. if vage<0


  rename v40191 vsex
    gen vfemale=vsex==0
    quietly replace vfemale=. if vsex==-6
  rename v40261 vinjury1
  rename v40271 vinjury2
  rename v40281 vinjury3
  rename v40291 vinjury4
  rename v40301 vinjury5
  rename v40311 oseqno1
  rename v40321 vrelate1
  rename v40331 oseqno2
  rename v40341 vrelate2
  rename v40351 oseqno3
  rename v40361 vrelate3
  rename v40371 oseqno4
  rename v40381 vrelate4
  rename v40391 oseqno5
  rename v40401 vrelate5
  rename v40411 oseqno6
  rename v40421 vrelate6
  rename v40431 oseqno7
  rename v40441 vrelate7
  rename v40451 oseqno8
  rename v40461 vrelate8
  rename v40471 oseqno9
  rename v40481 vrelate9
  rename v40491 oseqno10
  rename v40501 vrelate10
  rename v40201 vrace
  *No injury
  gen byte injuryNone=vinjury1==1
  *Serious injury
  *Minor injury
  gen byte injuryMinor= (vinjury1==2|vinjury2==2|vinjury3==2|vinjury4==2|vinjury5==2)

  gen byte injurySerious= !injuryMinor & !injuryNone & vinjury1!=-6

  rename v50061 oseqno
  rename v50071 oage
    replace oage=. if oage==0
  rename v50081 osex
    gen ofemale=osex==0
    quietly replace ofemale=. if osex==-6
rename v50091 orace


  keep ori rep* cfips* monthsreported pop* city stabb agency_indic pop_group date* ino idate ihour datereport offensecode offusing* location weapon* vage vfemale injuryN injuryM injuryS vrelate* vseqno offense* oseq* vrace oseqno oage ofemale orace

drop offense7 offense8 offense9 offense10

  sort ori ino


save "raw/`i'_out", replace
}




di "year: 2013"
use "raw/2013_out", clear
forvalues i = 2014(1)2016 {
  di "year: `i'"
  append using "raw/`i'_out"
}


*save step1, replace


  ***Dates
g year = int(idate/10000)
g temp = idate-year*10000
g month = int(temp/100)
g day = temp - month*100
drop temp
g mdy = mdy(month,day,year)
g dow = dow(mdy)
g doy = doy(mdy)



*keep crimes against person


forv i = 1(1)6{
  rename offense`i' temp`i'
  gen offense`i' = "11A" if temp`i' == 111
  replace offense`i' = "11B" if temp`i' == 112
  replace offense`i' = "11C" if temp`i' == 113
  replace offense`i' = "36A" if temp`i' == 361
  replace offense`i' = "36B" if temp`i' == 362
  drop temp`i'
  }


rename vrace tempr
gen vrace = "W" if tempr == 1
replace vrace = "B" if tempr == 2
replace vrace = "O" if tempr > 2
drop tempr

rename orace tempr
gen orace = "W" if tempr == 1
replace orace = "B" if tempr == 2
replace orace = "O" if tempr > 2
drop tempr

rename date_added tempr
tostring tempr, gen(date_added)
drop tempr

rename date_nibrs tempr
tostring tempr, gen(date_nibrs)
drop tempr

rename pop2 tempr
tostring tempr, gen(pop2)
drop tempr

rename pop3 tempr
tostring tempr, gen(pop3)
drop tempr

rename pop4 tempr
tostring tempr, gen(pop4)
drop tempr

rename pop5 tempr
tostring tempr, gen(pop5)
drop tempr

rename datereport tempr
tostring tempr, gen(datereport)
drop tempr

*save step2, replace

drop pop_group rep_*

rename oseqno1 onum

rename cfips1 tempr
tostring tempr, gen(cfips1)
drop tempr

drop cfips2 cfips3 cfips4 cfips5



append using "raw/out_allyears"



   *Data is now at the offender-by-victim level. We now know what offenses an offender committed against a victim, their relationship to the victim, the location of each offense and whether substances were involved for each offense.
drop if monthsreported == 0

compress

gen idt = .
gen rdt = .

replace idt = mdy if datereport == "0"
replace rdt = mdy if datereport == "1"
replace idt = mdy if datereport == ""
replace rdt = mdy if datereport == "R"


keep date_nibrs ino pop* offense* vage oage vrace orace vfemale offusing* months* agency* city state_nibrs dow rep* month day stabb cfips* year ori mdy idt rdt

*keep if ori is actively reporting to NIBRS
g year_nibrs = substr(date_nibrs, 1,4)
destring year_nibrs, replace
keep if  year >= year_nibrs





*order stabb ori ino  year month
*sort stabb ori ino year month day

***Calculate outcome measures and collapse to daily crime counts***
g rape = 0

forv i = 1(1)6{
	replace  rape = 1 if offense`i'  == "11A" |  offense`i'== "11B" | offense`i'== "11C"
	}
	
*** MINE


forv i = 10(10)60{
	loc j = `i' + 9
	g rape_victim_`i'_to_`j' =(rape ==1 & vage >= `i' & vage <= `j')
}

g rape_victim_under_18 =(rape ==1 & vage < 18)

g rape_victim_18_to_24 = (rape ==1 & vage >= 18 & vage <= 24)


**********************

	g rape_v17_24_o_resid =(rape ==1 & vage >= 17 & vage <= 24 &  oage ==.)
	g rape_vic_res =(rape ==1 & vage ==.)

foreach i in 13 17 21 25{
loc j = `i' + 3

g rape_v17_24_o`i'_`j' =(rape ==1 & vage >= 17 & vage <= 24 &  oage >= `i' & oage <=`j')
g rape_vic_`i'_`j' = 0

	forv m = 1(1)6{
		replace rape_vic_`i'_`j' = 1 if (offense`m'  == "11A" | offense`m'== "11B" | offense`m'== "11C") & vage >= `i' & vage <=`j'

		}
}

g rape_vic_18_24 = 0
forv m = 1(1)6{
	replace rape_vic_18_24 = 1 if (offense`m'  == "11A" | offense`m'== "11B" | offense`m'== "11C") & vage >= 18 & vage <=24
	}

forv i = 1(1)3{
	g byte alc`i' = (offusing`i' == 1 | offusing`i' == 1 | offusing`i' == 1)

	}

	g rapealc = 0
	g rapenonalc = 0

forv i = 1(1)3{
	replace rapealc = 1 if alc`i' == 1 & (offense`i' == "11A" | offense`i'== "11B" | offense`i'== "11C")
	}

	replace rapenonalc = 1 if rapealc == 0

	*Rapes by Race
	g rape_vblk = (rape == 1 & vrace == "B")
	g rape_vwht = (rape == 1 & vrace == "W")
	g rape_voth = (rape == 1 & vrace != "W" & vrace != "B")
	
	g rape_vblk_17_24 =  (rape == 1 & vrace == "B" & vage >= 17 & vage <= 24)
	g rape_vwht_17_24 =  (rape == 1 & vrace == "W" & vage >= 17 & vage <= 24)
	g rape_voth_17_24 =  (rape == 1 & vrace != "W" & vrace != "B" & vage >= 17 & vage <= 24)


	g rape_oblk_17_24 =  (rape == 1 & orace == "B" & vage >= 17 & vage <= 24)
	g rape_owht_17_24 =  (rape == 1 & orace == "W" & vage >= 17 & vage <= 24)
	g rape_ooth_17_24 =  (rape == 1 & orace != "W" & orace != "B" & vage >= 17 & vage <= 24)

	*No Males
	g rape_femv_17_24 =(rape == 1 & vfemale == 1 & vage >= 17 & vage <= 24)
/*
	*Rapes by relationship
	cap drop known
	g known = (vrelate == "AQ" | vrelate == "FR" |  vrelate == "NE" | vrelate == "BE" | vrelate == "BG" | vrelate == "CF" | vrelate == "HR" | vrelate == "EE" | vrelate == "ER" | vrelate == "OK" | vrelate == "XS")
	g family = (vrelate == "SE" | vrelate == "CS" |  vrelate == "PA" | vrelate == "SB" | vrelate == "CH" | vrelate == "GP" | vrelate == "GC" | vrelate == "IL" | vrelate == "SP" | vrelate == "SC" | vrelate == "SS" | vrelate == "OF" | vrelate == "VO")


	g byte rape_spouse_17_24 = ((spouse == 1 | exspouse ==1 |commonspouse == 1) & rape == 1 & vage >= 17 & vage <= 24)
	g byte rape_bfriend_17_24 = (bgfriend == 1 & rape == 1 & vage >= 17 & vage <= 24)
	g byte rape_unkn_17_24 = (vrelate == "RU" & rape== 1 & vage >= 17 & vage <= 24)
	g byte rape_str_17_24 = ( vrelate == "ST" & rape== 1 & vage >= 17 & vage <= 24)
	g byte rape_kn_17_24 = (known == 1 & rape== 1 & vage >= 17 & vage <= 24)
	g byte rape_fam_17_24 = (family == 1 & rape== 1 & vage >= 17 & vage <= 24)
	g byte rape_aq_17_24 = (vrelate == "AQ" & rape== 1 & vage >= 17 & vage <= 24)
	g byte rape_friend_17_24 = (vrelate == "FR" & rape== 1 & vage >= 17 & vage <= 24)
	g byte rape_ne_17_24 = (vrelate == "NE" & rape== 1 & vage >= 17 & vage <= 24)
	g byte rape_hr_17_24 = (vrelate == "HR" & rape== 1 & vage >= 17 & vage <= 24)
*/
if 1 ==1{

foreach i in 17{
loc j = `i' + 7
	gen rapealc_vic_`i'_`j' = 0

	forv m = 1(1)3{
		replace rapealc_vic_`i'_`j' = 1 if alc`m' == 1 & (offense`m' == "11A" | offense`m'== "11B" | offense`m'== "11C") & vage >= `i' & vage <=`j'


		}
	}
}




rename pop1 population1

drop pop2 pop3 pop4 pop5

sort state_nibrs ori year month day

duplicates drop


*append groupB crimes:
*	append using "dataconstruction/datafiles\GroupB_1991_2012.dta"
*compress
keep  rape* population*  months* agency* city state_nibrs rep* stabb cfips* ori idt rdt ino
* drop otherfam


*save step3, replace

collapse (sum) rape* (firstnm) population*  months* agency* city ori state_nibrs rep* stabb cfips* idt rdt, by(ino) fast

save "raw/intermediate", replace


clear
use "clean/high_profile_events"
levelsof date, local(dates_of_events)

clear
set obs 500
set seed 98034
local a = 18099
local b = 20877
generate dates = floor((20877 - 18099 + 1)*runiform() + 18099)
levelsof dates, local(dates_of_placebo)

/*
foreach edate in `dates_of_placebo' {
	loc in_e = inlist(`edate',`dates_of_events')
	*display `in_e'
	forv i = 1(1)7{
		if inlist( `edate' - `i', `dates_of_events') == 1 {
			loc in_e = 1
		}
		if inlist( `edate' + `i', `dates_of_events') == 1 {
			loc in_e = 1
		}
		*loc l_dt = `edate' - `i'
		*loc r_dt = `edate' + `i'
		*replace `in_e' = 1 if (inlist( `edate' - `i', `dates_of_events') == 1)
	*	replace `in_e' = 1 if inlist(`edate' + `i', `dates_of_events') == 1
	}
	if `in_e' == 1{
		display `edate'
	}
}


foreach edate in `dates_of_placebo'{
	loc in_e = inlist(`edate',`dates_of_events')
	display `in_e'
}
*/


clear
use "raw/intermediate"

drop if rape == 0
* DO I DO THIS????

compress

keep rape idt rdt

drop if rdt == .
drop if idt == .

preserve
loc ldate = 20000 - 30
loc rdate = 20000 + 30
drop if idt > `rdate'
*drop if idt < `ldate'
drop if rdt < 20000
drop if rdt > `rdate'
collapse (sum) rape, by(idt) fast
g days_from_event = idt - 20000
g placebo = 1
save "clean/idt_analysis", replace
restore


foreach edate of local dates_of_events {
	preserve
	loc ldate = `edate' - 30
	loc rdate = `edate' + 30
	drop if idt > `rdate'
	*drop if idt < `ldate'
	drop if rdt < `edate'
	drop if rdt > `rdate'
	if _N > 0 {
		collapse (sum) rape, by(idt) fast
		g days_from_event = idt - `edate'
		g placebo = 0
		append using "clean/idt_analysis"
		save "clean/idt_analysis", replace
	}
	restore
}

foreach edate of local dates_of_placebo {
		preserve
		loc ldate = `edate' - 30
		loc rdate = `edate' + 30
		drop if idt > `rdate'
		*drop if idt < `ldate'
		drop if rdt < `edate'
		drop if rdt > `rdate'
		if _N > 0 {
			collapse (sum) rape, by(idt) fast
			g days_from_event = idt - `edate'
			g placebo = 1
			append using "clean/idt_analysis"
			save "clean/idt_analysis", replace
		}
		restore
}
