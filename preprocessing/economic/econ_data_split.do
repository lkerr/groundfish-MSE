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

replace spstock2=lower(spstock2)
replace spstock2=subinstr(spstock2,"ccgom","CCGOM",.)
replace spstock2=subinstr(spstock2,"snema","SNEMA",.)
replace spstock2=subinstr(spstock2,"gom","GOM",.)

replace spstock2=subinstr(spstock2,"gb","GB",.)

save "$inputdir/data_for_simulations_mse.dta", replace



foreach gfy of numlist 2010(1)2015{
clear
use "$inputdir/data_for_simulations_mse.dta" if gffishingyear==`gfy'
cap drop spstock year hullnum2

save "$inputdir/econ_data_`gfy'.dta", replace
}

