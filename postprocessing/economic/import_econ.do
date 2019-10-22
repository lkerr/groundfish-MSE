/* Order of doing stuff. */
/* Run this file to load/prep the economic data */
version 15.1
global projectdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE"

global raw_results "$projectdir/results/econ/raw"
global process_results "$projectdir/results/econ/process"
global codedir "$projectdir/postprocessing/economic"

cap mkdir $process_results


cd $raw_results
local imports: dir "." files "*.csv"

foreach l of local imports{
	tempfile new
	local files `"`files'"`new'" "'  
	clear
	import delimited `l'
	qui save `new'
}

dsconcat `files'
save "$process_results/results.dta", replace

gen caldate=mdy(5,1,y)+doffy-1

/* targets by day, across replicates */
gen target=1
collapse (count) target, by(caldate spstock2 r m)

encode spstock2, gen(mys)
tsset mys cal
xtline target
