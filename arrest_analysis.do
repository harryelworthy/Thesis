clear all

forv i = 2013(1)2016{
di "year: `i'"


  use "raw/`i'_raw"
  ren *, lower
  
  
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
  
  g rape = 0
  forv j = 1(1)6{
	replace  rape = 1 if offense`j'  == 111 |  offense`j'== 112 | offense`j'== 113
  }
  drop if rape == 0
  
  
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
   rename bh035 pop5
  destring pop1, replace


  *year specific

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

  drop offense7 offense8 offense9 offense10
  
    ***Dates
	g year = int(idate/10000)
	g temp = idate-year*10000
	g month = int(temp/100)
	g day = temp - month*100
	drop temp
	g mdy = mdy(month,day,year)
	g dow = dow(mdy)
	g doy = doy(mdy)



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


  destring pop2, replace
  destring pop3, replace
  destring pop4, replace
  destring pop5, replace


	   *Data is now at the offender-by-victim level. We now know what offenses an offender committed against a victim, their relationship to the victim, the location of each offense and whether substances were involved for each offense.
	drop if monthsreported == 0

	compress

	gen idt = .
	gen rdt = .

	replace idt = mdy if datereport == "0"
	replace rdt = mdy if datereport == "1"
	replace idt = mdy if datereport == ""
	replace rdt = mdy if datereport == "R"

	*keep if ori is actively reporting to NIBRS
	g year_nibrs = substr(date_nibrs, 1,4)
	destring year_nibrs, replace
	keep if  year >= year_nibrs

	g rape_arrest = 1
	replace rape_arrest = 0 if v60061 == -8

	  sort ori ino
	
save "raw/`i'_arrest_out", replace
}

di "year: 2013"
use "raw/2013_arrest_out", clear
forvalues i = 2014(1)2016 {
  di "year: `i'"
  append using "raw/`i'_arrest_out"
}

duplicates drop

collapse (sum) rape* (firstnm) idt rdt, by(ino) fast

preserve
g has_rdt = 0
replace has_rdt = 1 if rdt != .
g has_idt = 0
replace has_idt = 1 if idt != .
collapse (count) rape, by(has_idt has_rdt) fast
save "clean/rdt_numbers", replace
restore

preserve
drop if rdt = .
drop if idt = .
g same_day = 0
replace same_day = 1 if rdt == idt
collapse (count) rape, by(same_day) fast
save "clean/sameday_numbers", replace
restore

compress

collapse (sum) rape* , by(rdt) fast

save "clean/police_arrest", replace


