global inputdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"
global outdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_processed/econ"

/* prices are just at the species-date level, but we can build them at the spstock2-date level for merging convenience */

use "$inputdir/data_for_simulations_mse.dta", clear


keep spstock2 date price_lb price_lb_lag1

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

save "$inputdir/output_price_series.dta", replace


