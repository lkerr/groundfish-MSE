global inputdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"
global outdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_processed/econ"



*cd $inputdir
use "$inputdir/multipliers", clear

drop sppname gearcat calyear


replace spstock2=lower(spstock2)
replace spstock2=subinstr(spstock2,"ccgom","CCGOM",.)
replace spstock2=subinstr(spstock2,"snema","SNEMA",.)
replace spstock2=subinstr(spstock2,"gom","GOM",.)

replace spstock2=subinstr(spstock2,"gb","GB",.)


/*using l_ c_ and q_ as landings multiplier, catch multiplier, and quotaprice prefixes respectively */
rename landing_m l_
rename catch_m c_
rename aceprice q_


reshape wide l_ c_ q_, i(hullnum month gffishingyear spstock2_prim) j(spstock2) string

qui foreach var of varlist l_* c_* q_* {
replace `var'=0 if `var'==.
label variable `var' ""
}

compress
rename spstock2_prim spstock2

order hullnum month gffishingyear spstock2
sort hullnum month gffishingyear spstock2
notes drop _all

save "$inputdir/reshape_multipliers.dta", replace
