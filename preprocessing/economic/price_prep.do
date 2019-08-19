global inputdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"
global outdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_processed/econ"



*cd $inputdir
use "$inputdir/sample_DCdata_fys2009_2010_forML.dta", clear


keep spstock2 date price_lb 

keep spstock2 date price_lb
bysort spstock2 date: keep if _n==1
rename price_lb p_
reshape wide p_, i(date) j(spstock2) string
drop p_NoFish

foreach var of varlist p_* {
label var `var' ""
}

save "$inputdir/output_price_series.dta", replace
/* you'll want to merge this back to the DC data on "date" */


