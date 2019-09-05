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
 
    # data_for_simulations_mse.dta (main data file)
    # multipliers.dta (multipliers)
    # production_regs_actual_post_for_R.txt (production coefficients)
    # preCSasclogit2.ster
    # postCSasclogit2.ster


# This bit of code will run some stata.  
stata_exec<-"/usr/local/stata15/stata-mp"
#This one for windows0
#stata_opts<-" /b do" 
#this one for *nix
stata_opts <- "-b do"
stata_codedir <-"/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/preprocessing/economic"
stata_dofiles<-c("wrapper.do")
#stata_dofiles<-c("asclogit_coef_export.do", "stocks_in_model.do", "recode_catch_limits.do", "multiplier_prep.do","price_prep.do","econ_data_split.do")
stata_dofiles_list<-as.list(stata_dofiles)


# The lapply method hung, but it might just be that my code takes a long time.
# readin <-function(files){
#   full_cmd<-paste(stata_exec, stata_opts,file.path(stata_codedir,files) , sep=" ") 
#   system(full_cmd, timeout=0, intern=FALSE)
# }
# lapply(stata_dofiles, readin)
# 
# # This works, and satisfies my impatience to see some stuff appear on the screen.
# for (i in stata_dofiles) {
#      full_cmd<-paste(stata_exec, stata_opts,file.path(stata_codedir,i) , sep=" ") 
#      system(full_cmd, timeout=0, intern=FALSE)
#      print (paste("done with", i))
# }

# bits for targeting_coeff_import.R 
# file paths for the raw and final directories
# windows is kind of stupid, so you'll have to deal with it in some way.
rawpath <- './data/data_raw/econ'
savepath <- './data/data_processed/econ'
#rawpath <- 'C:/Users/Min-Yang.Lee/Documents/groundfish-MSE/data/data_raw/econ'
#savepath <- 'C:/Users/Min-Yang.Lee/Documents/groundfish-MSE/data/data_processed/econ'





#Which targeting coefs do you want to read in?
    # ML - uses post
    # AB - uses pre?
trawl_targeting_coef_source<-"asclogit_trawl_post_coefs.txt" 
gillnet_targeting_coef_source<-"asclogit_gillnet_post_coefs.txt"
#trawl_targeting_coef_source<-"asclogit_trawl_pre_coefs.txt" 
#gillnet_targeting_coef_source<-"asclogit_gillnet_pre_coefs.txt"

target_coef_outfile<-"targeting_coefs.Rds"

# bits for production_coefs.R 
#production_coef_pre<-"production_regs_actual_pre_forR.txt"
production_coef_post<-"production_regs_actual_post_forR.txt"
production_outfile<-"production_coefs.Rds"

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


# bits for targeting_data_import.R 
# Which multipliers, output prices, and input prices do you want to use.
multiplier_loc<-"sim_multipliers_post.Rds"
#multiplier_loc<-"sim_multipliers_pre.Rds"

output_price_loc<-"sim_prices_post.Rds"
input_price_loc<-"sim_post_vessel_stock_prices.Rds"
####prefix  (see datafile_split_prefix in wrapper.do)
yrstub<-"econ_data"



###########################Make sure you have the correct set of RHS variables.
spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
#spstock_equation=c("exp_rev_total",  "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")

choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")
#choice_equation=c("len" )


targeting_vars=c(spstock_equation, choice_equation)
production_vars=c("log_crew","log_trip_days","log_trawl_survey_weight","primary", "secondary", "constant")
production_vars<-c(production_vars, "constant")





source('preprocessing/economic/targeting_coeff_import.R')
source('preprocessing/economic/production_coefs.R')

source('preprocessing/economic/price_import.R')
source('preprocessing/economic/multiplier_import.R')
source('preprocessing/economic/vessel_specific_prices.R')


# This takes quite a while 
source('preprocessing/economic/targeting_data_import.R')

