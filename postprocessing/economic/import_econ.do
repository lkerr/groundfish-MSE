/* Order of doing stuff. */
/* Run this file to load/prep the economic data */
version 15.1
global projectdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE"

global raw_results "$projectdir/results/econ/raw"
global process_results "$projectdir/results/econ/process"
global codedir "$projectdir/postprocessing/economic"

cap mkdir $process_results

cd $raw_results

#local imports: dir "." files "econ_2019-10-22*.csv"

local imports: dir "." files "*.csv"

foreach l of local imports{
	tempfile new
	local files `"`files'"`new'" "'  
	clear
	import delimited `l'
	qui save `new'
}

dsconcat `files'
gen caldate=mdy(5,1,y)+doffy-1

save "$process_results/results.dta", replace


/* targets by day, across replicates */
gen target=1
gen month=mofd(caldate)
format month %tm

collapse (count) target, by(month spstock2 r m)

encode spstock2, gen(mys)
 keep if r==1 & m==1
tsset mys month
xtline target




use "$process_results/results.dta", replace
gen month=mofd(caldate)
format month %tm

collapse (sum) c_*, by(month r m)

keep if r==1 & m==1
tsset month

reshape long c_, i(r m month) j(spstock2) string
encode spstock2, gen(mys)
tsset mys month
xtline catch


