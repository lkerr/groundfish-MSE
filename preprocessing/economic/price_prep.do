global inputdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"
global outdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_processed/econ"

/* Construct prices at the spstock2-date level */

use "$inputdir/data_for_simulations_mse.dta", clear
cap notes drop _all
ds
local all `r(varlist)'
display "`all'"
foreach var of varlist _all {
	_strip_labels `var'
	label var `var' ""
}
save "$inputdir/data_for_simulations_mse.dta", replace


keep spstock2 post gffishingyear date price_lb price_lb_lag1
bysort spstock2 date: keep if _n==1


replace spstock2=lower(spstock2)
replace spstock2=subinstr(spstock2,"ccgom","CCGOM",.)
replace spstock2=subinstr(spstock2,"snema","SNEMA",.)
replace spstock2=subinstr(spstock2,"gom","GOM",.)
replace spstock2=subinstr(spstock2,"gb","GB",.)

rename price_lb_lag1 p_
rename price_lb r_
reshape wide p_ r_,  i(date) j(spstock2) string
drop p_nofish r_nofish

foreach var of varlist p_* r_*{
label var `var' ""
}

gen gfstart=mdy(5,1,gffishingyear)

gen doffy=date-gfstart+1
drop gfstart date
expand 2 if doffy==365, gen(myg)
replace doffy=366 if myg==1


bysort gffishingyear doffy: gen marker=_N
drop if marker==2 & myg==1
cap drop marker myg
bysort gffishingyear doffy: assert _N==1
order post gffishingyear doffy
sort post gffishingyear doffy
save "$inputdir/output_price_series.dta", replace



/*crew wage varies by vessel-spstock2 -- so does fuelprice */
use "$inputdir/data_for_simulations_mse.dta", clear
keep hullnum spstock2 post gffishingyear date wkly_crew fuelprice
gen gfstart=mdy(5,1,gffishingyear)


replace spstock2=lower(spstock2)
replace spstock2=subinstr(spstock2,"ccgom","CCGOM",.)
replace spstock2=subinstr(spstock2,"snema","SNEMA",.)
replace spstock2=subinstr(spstock2,"gom","GOM",.)
replace spstock2=subinstr(spstock2,"gb","GB",.)


/* pad out an extra day, where wkly_crew and fuel price for day 366 are equal to day=265 */
gen doffy=date-gfstart+1
expand 2 if doffy==365, gen(myg)
replace doffy=366 if myg==1

bysort hullnum spstock2 post gffishingyear doffy: gen marker=_N
drop if marker==2 & myg==1 
bysort hullnum spstock2 post gffishingyear doffy: assert _N==1

drop gfstart date myg marker
order post gffishingyear hullnum spstock2 doffy
sort post gffishingyear hullnum spstock2 doffy

save "$inputdir/hullnum_spstock2_input_prices.dta", replace



