global inputdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"
global outdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_processed/econ"



*cd $inputdir
foreach gfy of numlist 2010(1)2015{
clear
use "$inputdir/data_for_simulations_mse.dta" if gffishingyear==`gfy'
drop spstock year hullnum2
/*
local necessary q gffishingyear emean gearcat post h_hat choice id hullnum date spstock2 month 
local targeting_vars exp_rev_total fuelprice_distance distance mean_wind mean_wind_noreast permitted LApermit choice_prev_fish partial_closure start_of_season wkly_crew_wage len fuelprice fuelprice_len start_of_season
local production_vars  log_crew log_trip_days primary secondary log_trawl_survey_weight 

keep `necessary' `targeting_vars' `production_vars'
*/

merge m:1 date using "$inputdir/output_price_series.dta", keep(1 3)
assert _merge==3
cap drop _merge

/*_merge==2 comes in part from slicing on year  */

merge m:1 hullnum month gffishingyear spstock2 using "$inputdir/reshape_multipliers.dta", keep(1 3)

assert spstock2=="NoFish" if _merge==1

drop _merge

save "$inputdir/econ_data_`gfy'.dta", replace
}



