global inputdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"
global outdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_processed/econ"



*cd $inputdir
use "$inputdir/sample_DCdata_fys2009_2010_forML.dta", clear
merge m:1 date using "$inputdir/output_price_series.dta"
assert _merge==3
cap drop _merge

merge m:1 hullnum month gffishingyear spstock2 using "$inputdir/reshape_multipliers.dta"

assert spstock2=="NoFish" if _merge==1

assert _merge~=2
drop if _merge==2
drop _merge

save "$inputdir/extra_DCdata_fys2009_2010_forML.dta", replace
/* you'll want to merge this back to the DC data on "date" */


