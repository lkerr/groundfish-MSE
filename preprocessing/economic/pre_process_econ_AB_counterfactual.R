# Preliminary data processing for the model counterfactual  
# Model validation "post-as-pre" uses
#       Pre- production, pre multipliers,
#       pre-choice coefficients, 
#       slightly adjusted data. 
#       post prices

# Nearly all of this code is setting parameters that get passed through to other .R files. 

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
    # Logic coefficients: preCSasclogit2.ster,postCSasclogit2.ster
    # 
############################################################
#This is my attempt to get R to run stata. It's not quite working properly, so I've commented it out.
# This bit of code will run some stata.  
#stata_exec<-"/usr/local/stata15/stata-mp"
#This one for windows0
#stata_opts<-" /b do" 
#this one for *nix
#stata_opts <- "-b do"
#stata_codedir <-"/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/preprocessing/economic"
#stata_dofiles<-c("wrapperAB.do")
#stata_dofiles<-c("asclogit_coef_export.do", "stocks_in_model.do", "recode_catch_limits.do", "multiplier_prep.do","price_prep.do","econ_data_split.do")
#stata_dofiles_list<-as.list(stata_dofiles)


# doesn't quite work -- the quotes aren't in the right place
#full_cmd<-paste(stata_exec, stata_opts,file.path(stata_codedir,stata_dofiles) , sep=" ") 
#system(full_cmd, timeout=0, intern=FALSE)
############################################################



# file paths for the raw and final directories
# windows is kind of stupid, so you'll have to deal with it in some way.
rawpath <- './data/data_raw/econ'
savepath <- './data/data_processed/econ'
#rawpath <- 'C:/Users/Min-Yang.Lee/Documents/groundfish-MSE/data/data_raw/econ'
#savepath <- 'C:/Users/Min-Yang.Lee/Documents/groundfish-MSE/data/data_processed/econ'



###########################Make sure you have the correct set of RHS variables.
spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
#spstock_equation=c("exp_rev_total",  "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")
targeting_vars=c(spstock_equation, choice_equation)

production_vars_pre=c("log_crew","log_trip_days","log_trawl_survey_weight","primary", "secondary")
production_vars_post=c("log_crew","log_trip_days","log_trawl_survey_weight","log_sector_acl","primary", "secondary")

####################Locations of files. You shouldn't have to change these unless you're adding new datasets (like a pre-as-pre or pre-as-pre), new coefficients, new multipliers, etc) 
trawl_targeting_post<-"asclogit_trawl_post_coefs.txt" 
gillnet_targeting_post<-"asclogit_gillnet_post_coefs.txt"
trawl_targeting_pre<-"asclogit_trawl_pre_coefs.txt" 
gillnet_targeting_pre<-"asclogit_trawl_pre_coefs.txt" 

target_pre_out<-"targeting_coefs_pre.Rds"
target_post_out<-"targeting_coefs_post.Rds"


# bits for production_coefs.R 
production_coef_pre<-"production_regs_actual_pre_forR.txt"
production_coef_post<-"production_regs_actual_post_forR.txt"

prodution_pre_out<-"production_coefs_pre.Rds"
prodution_post_out<-"production_coefs_post.Rds"

# bits for price_import.R 
price_location<-"output_price_series.dta"
pricepreoutfile<-"sim_prices_pre.Rds"
pricepostoutfile<-"sim_prices_post.Rds"

# bits for multiplier_import.R 
multip_location<-"reshape_multipliers.dta"
multipreoutfile<-"sim_multipliers_pre.Rds"
multipostoutfile<-"sim_multipliers_post.Rds"

# bits for vessel_specific_prices.R 
vsp_location<-"hullnum_spstock2_input_prices.dta"
vsp_preoutfile<-"sim_pre_vessel_stock_prices.Rds"
vsp_postoutfile<-"sim_post_vessel_stock_prices.Rds"

####################END Locations of files. You shouldn't have to change these unless you're adding new datasets (like a pre-as-pre or pre-as-pre), new coefficients, new multipliers, etc) 



#Which targeting coefs do you want to read in?
# counterfactual: pre for production and pre for choice
# validation: post for production and pre for choice

# Tell R which targeting coefficients to read in and where to store them.
trawl_targeting_coef_source<-trawl_targeting_pre
gillnet_targeting_coef_source<-gillnet_targeting_pre
target_coef_outfile<-target_pre_out

# OR target_coef_outfile<-target_post_out
# OR trawl_targeting_coef_source<-trawl_targeting_post
# OR gillnet_targeting_coef_source<-gillnet_targeting_post


# Tell R which production coefficients to read in and where to store them.
production_coef_in<-production_coef_pre
production_outfile<-prodution_pre_out 
# OR
#  production_coef_in<-production_coef_post
#  production_outfile<-prodution_post_out


# bits for targeting_data_import.R 
# Which multipliers, output prices, and input prices do you want to use.
# the targeting_data_import.R code will handle 

multiplier_loc<-multipreoutfile
# OR 
# multiplier_loc<-multipostoutfile
output_price_loc<- pricepostoutfile
input_price_loc<-vsp_postoutfile

####prefix  (see datafile_split_prefix in wrapper.do)
yrstub<-"POSTasPRE"


production_vars<-c(production_vars_pre, "constant")
useful_vars=c("gearcat","post","h_hat","choice", "log_h_hat")
#useful_vars=c("gearcat","post","h_hat","xb_post","choice")

yearly_savename<-"counterfactual"


source('preprocessing/economic/targeting_coeff_import.R')
source('preprocessing/economic/production_coefs.R')

source('preprocessing/economic/price_import.R')
source('preprocessing/economic/multiplier_import.R')
source('preprocessing/economic/vessel_specific_prices.R')


# This takes quite a while 
source('preprocessing/economic/targeting_data_import.R')

