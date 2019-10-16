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
global datafilename "data_for_simulations_POSTasPRE.dta"
global datafile_split_prefix "POSTasPRE"

/*construct prices, reshape multipliers, and bring both into the targeting dataset */
global catch_hist_file "catchHist.csv"

/*name of multiplier file*/

global multiplier_file "multipliers.dta"
global multiplier_out "reshape_multipliers.dta"

/* done */
do "$codedir/asclogit_coef_export.do"
do "$codedir/stocks_in_model.do"
do "$codedir/recode_catch_limits.do"
do "$codedir/price_prep.do"
do "$codedir/multiplier_prep.do"
do "$codedir/econ_data_split.do"

/* to do 


do "$codedir/price_mult_join.do"*/




/*obsolete 
do "$codedir/nlogit_coef_export.do" */
