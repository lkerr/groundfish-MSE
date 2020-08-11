version 15.1

/* Run this file to load/prep the economic data that is common for all scenarios.
This set of data processing is the same for all of the different scenarios.
So we only need to run this once. And run this before you run the other wrappers

*/
global projectdir $MSEprojdir 
*global projectdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE"
*global projectdir "C:/Users/abirken/Documents/GitHub/groundfish-MSE"

global inputdir "$projectdir/data/data_raw/econ"
global outdir "$projectdir/data/data_processed/econ"
global codedir "$projectdir/preprocessing/economic"
global bio_data "$projectdir/data/data_processed/catchHistory"



/* read in and minimal process the targeting equations */
/* There are a bunch; we'll read them all in */
/* filenames for sters and outputs*/

/* NC2 models */
/*
global post_input_ster "postCSasclogitnc2.ster"


global post_gillnet_out "asclogit_gillnet_post_coefsnc2.txt"
global post_trawl_out "asclogit_trawl_post_coefsnc2.txt"
*/

global pre_input_ster "preCSasclogitnc2.ster"
global pre_gillnet_out "asclogit_gillnet_pre_coefsnc2.txt"
global pre_trawl_out "asclogit_trawl_pre_coefsnc2.txt"


do "$codedir/asclogit_coef_export.do"


/* NC1 models */
/* This is a bit of a hack. 
the asclogit_coef_export.do file takes the post and pre sters and turns them into something.
We only have 1 post versions. Rather than fixing up asclogit_coef_export. I'm just not going to reset the globals
that means it will read the post_nc2 again and again. But that's okay   
global post_input_ster "postCSasclogitnc1.ster"
global post_gillnet_out "asclogit_gillnet_post_coefsnc1.txt"
global post_trawl_out "asclogit_trawl_post_coefsnc1.txt"
*/

global pre_input_ster "preCSasclogitnc1.ster"
global pre_gillnet_out "asclogit_gillnet_pre_coefsnc1.txt"
global pre_trawl_out "asclogit_trawl_pre_coefsnc1.txt"


do "$codedir/asclogit_coef_export.do"


/* 1 models */
global pre_input_ster "preCSasclogit1.ster"
global pre_gillnet_out "asclogit_gillnet_pre_coefs1.txt"
global pre_trawl_out "asclogit_trawl_pre_coefs1.txt"

do "$codedir/asclogit_coef_export.do"

/* 2 models */
global pre_input_ster "preCSasclogit2.ster"
global pre_gillnet_out "asclogit_gillnet_pre_coefs2.txt"
global pre_trawl_out "asclogit_trawl_pre_coefs2.txt"

do "$codedir/asclogit_coef_export.do"




/*construct prices, reshape multipliers, and bring both into the targeting dataset */
global catch_hist_file "catchHist.csv"

/*name of multiplier file*/

global multiplier_file "multipliers.dta"
global multiplier_out "reshape_multipliers.dta"

global datafilename "data_for_simulations_POSTasPOST.dta"






do "$codedir/stocks_in_model.do"

do "$codedir/recode_catch_limits.do"
do "$codedir/multiplier_prep.do"

