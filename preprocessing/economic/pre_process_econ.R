# Setting up the data.
# Before you do anything, you put these files into the 
# /data/data_raw/econ folder
# 
# data_for_simulations_mse.dta (main data file)
# multipliers.dta (multipliers)
# production_regs_actual_post_for_R.txt (production coefficients)
# preCSasclogit2.ster
# postCSasclogit2.ster

# you then run I wrote a wrapper (wrapper.do) to do all these
# If you're smart you'll call this from R  .......stata-mp wrapper.do
# asclogit_coef_export.do
# multiplier_prep.do
# price_prep.do
# stocks_in_model.do
# recode_catch_limits.do

source('preprocessing/economic/targeting_coeff_import.R')
source('preprocessing/economic/production_coefs.R')
source('preprocessing/economic/targeting_data_import.R')
source('preprocessing/economic/price_import.R')


source('preprocessing/economic/multiplier_import.R')
source('preprocessing/economic/vessel_specific_prices.R')
