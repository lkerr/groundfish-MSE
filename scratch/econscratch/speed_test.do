
use "$inputdir/data_for_simulations_mse.dta", clear
est use "preCSasclogit2.ster", number(1)
est store gillnets
local gear GILLNETS
local t 18383

timer clear


/* simulate loading a subset, predicting and loading the next day and merging in the choice*/
timer on 5

use "$inputdir/data_for_simulations_mse.dta" if gear=="GILLNETS" & date==`t', clear
predict pr5, pr

gen lastchoice=pr
keep hullnum _j lastchoice
tempfile saver
save `saver'

local ++t
use "$inputdir/data_for_simulations_mse.dta" if gear=="GILLNETS" & date==`t', clear
merge 1:1 hullnum _j using `saver'
assert _merge==3
drop _merge 
timer off 5
timer list


/*base way*/
cap drop pr
timer on 1
predict pr if gearcat=="`gear'" & date==`t', pr
timer off 1

/*do the logical check first, then predict */
timer on 2
estimates esample: if gearcat=="`gear'" & date==`t'
predict pr2 if e(sample), pr
timer off 2
/*do the logical check first, then predict */
timer on 22
gen markin=(gearcat=="`gear'" & date==`t')
predict pr22 if markin, pr
timer off 22



/*predict everything, then drop */
timer on 3
predict pr3, pr
replace pr3=0 if (gearcat~="`gear'" & date~=`t')
timer off 3




/*keep just gillnets*/

timer on 4
keep if gear=="GILLNETS"
predict pr4 if date==`t', pr
timer off 4
timer list


timer on 44
cap drop markin
gen markin=date==`t'
predict pr44 if markin,  pr
timer off 44

timer list


