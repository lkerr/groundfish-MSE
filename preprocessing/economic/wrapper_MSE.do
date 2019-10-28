/* Order of doing stuff. */
/* Run this file to load/prep the economic data */
global projectdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE"

*global projectdir "C:/Users/abirken/Documents/GitHub/groundfish-MSE"
global inputdir "$projectdir/data/data_raw/econ"
global outdir "$projectdir/data/data_processed/econ"
global codedir "$projectdir/preprocessing/economic"
global bio_data "$projectdir/data/data_processed/catchHistory"




/* filenames for sters  and outputs*/
global post_input_ster "postCSasclogitnc2.ster"
global post_gillnet_out "asclogit_gillnet_post_coefs.txt"
global post_trawl_out "asclogit_trawl_post_coefs.txt"


global pre_input_ster "preCSasclogitnc2.ster"
global pre_gillnet_out "asclogit_gillnet_pre_coefs.txt"
global pre_trawl_out "asclogit_trawl_pre_coefs.txt"


/*name of main data file */
global datafilename "data_for_simulations_mse.dta"
global datafile_split_prefix "econ_data"

/*construct prices, reshape multipliers, and bring both into the targeting dataset */
global catch_hist_file "catchHist.csv"

/*name of multiplier file*/

global multiplier_file "multipliers.dta"
global multiplier_out "reshape_multipliers.dta"
global quota_price_out "reshape_quota_pricesMSE.dta"


/*filenames for input prices and output prices */
global output_prices "output_price_series_MSE.dta"
global input_prices "input_price_series_MSE.dta"


do "$codedir/price_prep.do"
do "$codedir/econ_data_split.do"

/*obsolete 
do "$codedir/nlogit_coef_export.do" */
