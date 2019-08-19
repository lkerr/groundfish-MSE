/* Order of doing stuff. */
/* Run this file to load/prep the economic data */
global inputdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"
global outdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_processed/econ"

global codedir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/preprocessing/economic"


/*construct prices, reshape multipliers, and bring both into the targeting dataset */
do "$codedir/price_prep.do"
do "$codedir/multiplier_prep.do"
do "$codedir/price_mult_join.do"

/*obsolete 
do "$codedir/nlogit_coef_export.do" */

do "$codedir/asclogit_coef_export.do"
do "$codedir/recode_catch_limits.do"
do "$codedir/stocks_in_model.do"


