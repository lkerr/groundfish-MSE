


## ---- Overwrite/update SIMULATION PARAMETERS for the economic counterfactual ---- ##

#### Helpful parameters ####
# Scalars to convert things
pounds_per_kg<-2.20462
kg_per_mt<-1000
# Set the economic years that we'll use for simulation.  Right now, we'll pass  in 1 year.

first_econ_yr<-2010
last_econ_yr<-2015

econdatapath <- 'data/data_processed/econ'


#multiplier_loc<-"sim_multipliers_pre.Rds"

multiplier_loc<-"sim_multipliers_post.Rds"
output_price_loc<-"sim_prices_post.Rds"
input_price_loc<-"sim_post_vessel_stock_prices.Rds"


##############Stocks in the Economic Model #############################
spstock2s<-c("americanlobster","americanplaiceflounder","codGB","codGOM","haddockGB","haddockGOM","monkfish", "other","pollock","redsilveroffshorehake","redfish","seascallop","skates","spinydogfish","squidmackerelbutterfishherring","summerflounder","whitehake","winterflounderGB","winterflounderGOM","witchflounder","yellowtailflounderCCGOM", "yellowtailflounderGB","yellowtailflounderSNEMA")

##############Independent variables in the targeting equation ##########################
spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
#choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len", "das_price_mean", "das_price_mean_len")
choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")

##############Independent variables in the Production equation ##########################
production_vars=c("log_crew","log_trip_days","primary","secondary", "log_trawl_survey_weight","constant")









# Read in Economic Production Data. These are relatively lists of data.tables. So it makes sense to read in once and then list-subset [[]] later on.

multipliers<-readRDS(file.path(econdatapath,multiplier_loc))
outputprices<-readRDS(file.path(econdatapath,output_price_loc))
inputprices<-readRDS(file.path(econdatapath,input_price_loc))






