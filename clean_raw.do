/*



*This file reads in and organizes nibrs data for all years
* Data from: https://www.icpsr.umich.edu/icpsrweb/NACJD/search/studies?q=NIBRS&
* Extract Files
* AND from: https://www.openicpsr.org/openicpsr/project/100462/version/V3/view?path=/openicpsr/100462/fcr:versions/V3/Data-Construction/Data-Files/orischool.xls&type=file
clear all


/*
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


*/

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



gen idt = mdy if datereport == ""
gen rdt = mdy if datereport == "R"


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
		
forv i = 1(1)3{
	replace rapealc = 1 if alc`i' == 1 & (offense`i' == "11A" | offense`i'== "11B" | offense`i'== "11C")
	}
	
	*Rapes by Race
	
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

* DO I DO THIS???? 

compress

preserve

replace rdt = idt if rdt == .


/*
	
***merge in missing county IDs***
	replace stabb = "NE" if stabb == "NB"
	rename cfips1 countyfips
	destring countyfips, replace
	mmerge stabb using dataconstruction\datafiles\UCR_FIPS_stateXwalk.dta 
	drop if _merge == 2
	
	preserve
		use dataconstruction\datafiles\04634-0001-Data.dta, clear 
	rename LONG LONGI
	rename *, lower
	rename fstate statefips
	rename fcounty countyfipsalt
	rename ori9 ori
	drop if ori == ""
	tempfile Xwalk
	save "`Xwalk'", replace
	restore
 
	*merge in county crosswalk
	mmerge ori using "`Xwalk'"
	drop if _merge == 2
	destring countyfips, replace force
	replace countyfips = countyfipsalt if countyfips == .
	
*/

g year = year(rdt)


collapse (sum) rape* (firstnm) population*  months* agency* city state_nibrs rep* stabb cfips*, by(ori year) fast
	
	
save "clean/police_yearly", replace


restore

preserve

replace rdt = idt if rdt == .

*keep  rape* population*  months* agency* city state_nibrs dow rep* month day stabb cfips* year ori mdy sundayofweek
* drop otherfam 

gen sundayofweek = cond(dow(rdt) == 0, rdt, rdt - dow(rdt)) 

collapse (sum) rape* (firstnm) population*  months* agency* city state_nibrs rep* stabb cfips*, by(sundayofweek) fast

/*
	
***merge in missing county IDs***
	replace stabb = "NE" if stabb == "NB"
	rename cfips1 countyfips
	destring countyfips, replace
	mmerge stabb using dataconstruction\datafiles\UCR_FIPS_stateXwalk.dta 
	drop if _merge == 2
	
	preserve
		use dataconstruction\datafiles\04634-0001-Data.dta, clear 
	rename LONG LONGI
	rename *, lower
	rename fstate statefips
	rename fcounty countyfipsalt
	rename ori9 ori
	drop if ori == ""
	tempfile Xwalk
	save "`Xwalk'", replace
	restore
 
	*merge in county crosswalk
	mmerge ori using "`Xwalk'"
	drop if _merge == 2
	destring countyfips, replace force
	replace countyfips = countyfipsalt if countyfips == .
	
*/	
	
	
save "clean/police_weekly", replace

restore

drop if rdt == .
drop if idt == .

gen timewaited = rdt - idt
gen waitover7 = timewaited > 7
gen waitover30 = timewaited > 30
gen waitover365 = timewaited > 365

preserve

g year = year(rdt)


collapse (sum) rape* waitover* (mean) timewaited (firstnm) population*  months* agency* city state_nibrs rep* stabb cfips*, by(ori year) fast

save yearlyplus, replace

restore

gen sundayofweek = cond(dow(rdt) == 0, rdt, rdt - dow(rdt)) 

collapse (sum) rape* waitover* (mean) timewaited (firstnm) population*  months* agency* city state_nibrs rep* stabb cfips*, by(sundayofweek) fast

save "clean/police_weekly_reportdates", replace

clear

*/






/*
Data from https://ope.ed.gov/campussafety/#/datafile/list
Download all excel files and put them in same folder as this file, then set working directory to that folder
*/

* 2008
clear
import excel "raw/Crime2008EXCEL/oncampuscrime050607.xls", sheet("Oncampuscrime050607") firstrow

* Need to add a 0 to middle of id's, was done in 2010, annoying!
tostring UNITID_P, gen(strid)
gen newst = substr(strid, 1, 6) + "0" + substr(strid, 7, 8)
destring newst, gen(newint)
drop UNITID_P
rename newint UNITID_P
drop newst strid

* Make zip string and change name
tostring Zip, gen(ZIP)
drop Zip
* Rename to fit 2009/2010 naming changes
rename sector_desc Sector_desc
rename total Total

save "raw/2008", replace


* 2009
clear
import excel "raw/Crime2009EXCEL/oncampuscrime060708.xls", sheet("Oncampuscrime060708") firstrow

* As above
tostring UNITID_P, gen(strid)
gen newst = substr(strid, 1, 6) + "0" + substr(strid, 7, 8)
destring newst, gen(newint)
drop UNITID_P
rename newint UNITID_P
drop newst strid

tostring Zip, gen(ZIP)
drop Zip

rename sector_desc Sector_desc

save "raw/2009", replace


* 2010
clear
import excel "raw/Crime2010EXCEL/oncampuscrime070809.xls", sheet("Oncampuscrime070809") firstrow
save "raw/2010", replace


* 2011
clear
import excel "raw/Crime2011EXCEL/oncampuscrime080910.xls", sheet("Oncampuscrime080910") firstrow
save "raw/2011", replace


* 2012
clear
import excel "raw/Crime2012EXCEL/oncampuscrime091011.xls", sheet("Sheet1") firstrow
save "raw/2012", replace


* 2013
clear
import excel "raw/Crime2013EXCEL/oncampuscrime101112.xls", sheet("oncampuscrime101112") firstrow
save "raw/2013", replace


* 2014
clear
import excel "raw/Crime2014EXCEL/oncampuscrime111213.xls", sheet("CO_OC") firstrow
save "raw/2014", replace


* 2015
clear
import excel "raw/Crime2015EXCEL/oncampuscrime121314.xls", sheet("CO_OC") firstrow
save "raw/2015", replace


* 2016
clear
import excel "raw/Crime2016EXCEL/oncampuscrime131415.xls", sheet("Query") firstrow
save "raw/2016", replace


* 2017
clear
import excel "raw/Crime2017EXCEL/oncampuscrime141516.xls", sheet("Query") firstrow
save "raw/2017", replace

* Merge all together. In this order so later reports take precedent, eg any revisions made in 2017 numbers will stay
merge 1:1 UNITID_P using raw/2008, nogen
merge 1:1 UNITID_P using raw/2009, nogen
merge 1:1 UNITID_P using raw/2010, nogen
merge 1:1 UNITID_P using raw/2011, nogen
merge 1:1 UNITID_P using raw/2012, nogen
merge 1:1 UNITID_P using raw/2013, nogen
merge 1:1 UNITID_P using raw/2014, nogen
merge 1:1 UNITID_P using raw/2015, nogen
merge 1:1 UNITID_P using raw/2016, nogen

* Reshape to use in panel
reshape long RAPE FONDL INCES STATR FORCIB NONFOR MURD NEG_M ROBBE AGG_A BURGLA VEHIC ARSON FILTER, i(UNITID_P) j(year)

* Drop non-used vars
drop MURD NEG_M ROBBE AGG_A BURGLA VEHIC ARSON FILTER FILTER05 FILTER06 FILTER07 FILTER08 FILTER09 Address

* Rename nicer
rename UNITID_P id
rename INSTNM school
rename BRANCH branch
rename City city
rename State state
rename ZIP zip
rename Sector_desc sector_desc
rename Total total
rename RAPE rape
rename FONDL fondl
rename INCES inces
rename STATR statr
rename FORCIB forcib
rename NONFOR nonforcib

* Sum schools with same year, same name, i.e. different branches of same school
* These create issues as the student count is for entire system, this summing reports makes sense
bysort school year: replace rape = sum(rape) 
bysort school year: replace fondl = sum(fondl) 
bysort school year: replace inces = sum(inces)
bysort school year: replace statr = sum(statr)  
bysort school year: replace forcib = sum(forcib) 
bysort school year: replace nonforcib = sum(nonforcib)
by school year: keep if _n == _N 

* Create combined var for all reports, incl different classifications before/after 2014
gen comb = rape + fondl + inces + statr
replace comb = forcib + nonforcib if year < 14

* Create dummy for after 2011 
gen after_2011 = 0
replace after_2011 = 1 if year > 11

* Drop if no student count
drop if total == .

* Create reports per student var
gen percap = comb/total

tostring id, gen(stridp)
gen stridr = substr(stridp, 1, 6)
destring stridr, gen(unitid)
drop stridp stridr

replace year = year + 2000

save "clean/school_full", replace




* ADDITIONAL PARAMS


do "raw/add_school_params/hd2016.do"
* use "/Users/harry/Google Drive/GDocuments/F18/Thesis/DATA/Data Cleaning and Analysis/dct_hd2017.dta", clear

keep unitid zip obereg opeid opeflag sector iclevel control hbcu tribal medical locale act cyactive cbsa csa countycd cngdstcd 

save "raw/tempf", replace

/*
do "raw/add_school_params/ef2016a.do"

keep if efalevel == 1
drop if eftotlt == .

gen per_white = efwhitt/eftotlt
gen per_min = (efaiant + efasiat + efbkaat + efhispt + efnhpit)/eftotlt
gen per_black = efbkaat/eftotlt
gen per_hisp = efhispt/eftotlt

keep unitid per_*

merge 1:1 unitid using "raw/tempf"
drop if _merge != 3
drop _merge

save "raw/tempf", replace


do "raw/add_school_params/sfa1516.do"

keep unitid uagrnta upgrntp grnta2

merge 1:1 unitid using "raw/tempf"
drop if _merge != 3
drop _merge

save "raw/tempf", replace



do "raw/add_school_params/adm2016.do"

drop if applcn == .
gen admrate = admssn/applcn
gen enrlrate = enrlt/applcn

keep unitid admrate enrlrate

merge 1:1 unitid using "raw/tempf"
drop if _merge != 3
drop _merge

save "raw/tempf", replace

clear
insheet using "raw/add_school_params/MERGED2015_16_PP.csv", comma clear
rename UNITID unitid
keep unitid sat_avg distanceonly curroper npt4_p* pctfloan cdr* md_earn_wne_p10 mn_earn_wne_p10
replace npt4_pub = npt4_priv if npt4_pub == "NULL"
replace npt4_pub = "" if npt4_pub == "NULL"
destring npt4_pub, gen(price)
drop npt4_*

merge 1:1 unitid using "raw/tempf"
drop if _merge != 3
drop _merge

save "raw/tempf", replace

*/
clear
use raw/full

merge m:1 unitid using "raw/tempf"
drop if _merge != 3
drop _merge
/*
save "raw/tempf", replace

clear
insheet using "/Users/harry/Google Drive/GDocuments/F18/Thesis/DATA/Data Cleaning and Analysis/add_school_params/election/US_County_Level_Presidential_Results_08-16.csv", comma clear

rename fips_code countycd

reshape long total_ dem_ gop_ oth_, i(countycd) j(year)  

gen per_dem = dem_/total_
gen per_gop = gop_/total_

drop if year < 2015

keep per* countycd

merge 1:m countycd using "raw/tempf"

drop if _merge != 3
drop _merge
*/

save "clean/school_full_plus", replace



* CASES

*** MISSING JSON IN HOW DID I DO THAT

clear
use "raw/cases"

estimates clear
split opened ,g(part) p("-")

g tmp = part1 + part2 + part3

 // transfer to date
g date_op = date(tmp, "YMD")
form date_op %td


drop part? tmp opened

rename college_unitid id6s

save "clean/all_cases", replace


egen first_date_school = min(date_op), by(id6s)
form first_date_school %td

drop if (first_date_school != date_op)

duplicates drop 

save "clean/first_cases", replace







**** TRENDS

clear
import delimited "raw/SA.csv", varnames(3) 

split week ,g(part) p("/")
g tmp = part1 + part2 + part3
drop week
// transfer to date
g week = date(tmp, "DMY")
form week %td
// clean up
drop part? tmp

duplicates drop week, force

rename normalized SA_norm

save "clean/SA", replace

clear
import delimited "raw/r.csv", varnames(3) 

split week ,g(part) p("/")
g tmp = part1 + part2 + part3
drop week
// transfer to date
g week = date(tmp, "DMY")
form week %td
// clean up
drop part? tmp

duplicates drop week, force

rename normalized r_norm

save "clean/r", replace

clear
import delimited "raw/bn.csv", varnames(3) 

split week ,g(part) p("/")
g tmp = part1 + part2 + part3
drop week
// transfer to date
g week = date(tmp, "DMY")
form week %td
// clean up
drop part? tmp

duplicates drop week, force

rename normalized bn_norm

save "clean/bn", replace

clear
import delimited "raw/b.csv", varnames(3) 

split week ,g(part) p("/")
g tmp = part1 + part2 + part3
drop week
// transfer to date
g week = date(tmp, "DMY")
form week %td
// clean up
drop part? tmp

duplicates drop week, force

rename normalized b_norm

save "clean/b", replace

merge 1:1 week using "clean/r"

drop _merge

merge 1:1 week using "clean/SA"
drop _merge

merge 1:1 week using "clean/bn"
drop _merge

save "clean/combtrends", replace


