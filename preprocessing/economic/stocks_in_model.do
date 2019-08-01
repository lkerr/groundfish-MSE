global inputdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"
global outdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_processed/econ"

use "$inputdir/sample_DCdata_fys2009_2010_forML.dta", clear
keep spstock2
dups, drop terse
drop _expand

save "$outdir/stocks_in_choiceset.dta", replace
