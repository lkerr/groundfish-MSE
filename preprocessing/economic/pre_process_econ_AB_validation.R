# Preliminary data processing for the model validation.  
# Model validation "post-as-post" uses
#       Post- production, post multipliers, post prices
#       pre-choice coefficients, 
#       slightly adjusted data. 
# 
rm(list=ls())
if(!require(readstata13)) {  
    install.packages("readstata13")
    require(readstata13)}
if(!require(tidyr)) {  
    install.packages("tidyr")
    require(tidyr)}
if(!require(dplyr)) {  
    install.packages("dplyr")
    require(dplyr)}
if(!require(data.table)) {  
    install.packages("data.table")
    require(data.table)}

# Setting up the data.
# Before you do anything, you put all your "data" files into the 
# /data/data_raw/econ folder
 
    # main data file: data_for_simulations_mse.dta, data_for_simulations_POSTasPOST.dta, data_for_simulations_POSTasPRE.dta
    # multipliers.dta (multipliers)
    # production coefficients:  production_regs_actual_post_for_R.txt,production_regs_actual_pre_for_R.txt
    # Logit coefficients: preCSasclogit2.ster,postCSasclogit2.ster


# file paths for the raw and final directories
# windows is kind of stupid, so you'll have to deal with it in some way.
rawpath <- './data/data_raw/econ'
savepath <- './data/data_processed/econ'
# Just a guess on your paths.  
#rawpath <- 'C:/Users/abirken/Documents/GitHub/groundfish-MSE/data/data_raw/econ'
#savepath <- 'C:/Users/abirken/Documents/GitHub/groundfish-MSE/data/data_processed/econ'



###########################Make sure you have the correct set of RHS variables.
spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")

choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")

targeting_vars=c(spstock_equation, choice_equation)

production_vars=c("log_crew","log_trip_days","log_trawl_survey_weight","log_sector_acl","primary", "secondary","constant")

####################Locations of files. 
# Validation uses pre-targeting coefficients
trawl_targeting_coef_source<-"asclogit_trawl_pre_coefs.txt" 
gillnet_targeting_coef_source<-"asclogit_gillnet_pre_coefs.txt" 

target_coef_outfile<-"targeting_coefs_pre.Rds"
#Validation uses post-production coefficients
production_coef_in<-"production_regs_actual_post_forR.txt"
production_outfile<-"production_coefs_post.Rds"


# bits for input_price_import.R 
file_suffix<-"_valid"

input_price_loc<-paste0("input_price_series",file_suffix,".dta")
input_preoutfile<-paste0("input_prices_pre",file_suffix,".Rds")
input_postoutfile<-paste0("input_prices_post",file_suffix,".Rds")
input_working<-input_postoutfile

# bits for multiplier_import.R 
multip_location<-"reshape_multipliers.dta"
multi_postoutfile<-paste0("sim_multipliers_post",file_suffix,".Rds")
multi_preoutfile<-paste0("sim_multipliers_pre",file_suffix,".Rds")
multiplier_working<-multi_postoutfile

# bits for output_price_import.R 
output_price_loc<-paste0("output_price_series",file_suffix,".dta")
output_preoutfile<-paste0("output_prices_pre",file_suffix,".Rds")
output_postoutfile<-paste0("output_prices_post",file_suffix,".Rds")
output_working<-output_postoutfile



####################END Locations of files. You shouldn't have to change these unless you're adding new datasets (like a pre-as-pre or pre-as-pre), new coefficients, new multipliers, etc) 

####prefix  (see datafile_split_prefix in wrapper.do)
yrstub<-"POSTasPOST"

yearly_savename<-"validation"

source('preprocessing/economic/targeting_coeff_import.R')
source('preprocessing/economic/production_coefs.R')
#output prices
source('preprocessing/economic/output_price_import.R')
source('preprocessing/economic/multiplier_import.R')
#input prices
source('preprocessing/economic/input_price_import.R')


# This takes quite a while 
source('preprocessing/economic/targeting_data_import.R')

