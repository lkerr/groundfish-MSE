version 15.1
est drop _all

/* Run this file to export coefficients from the quota price model */

global projectdir $MSEprojdir 
global inputdir "$projectdir/data/data_raw/econ"
global outdir "$projectdir/data/data_processed/econ"

global input_ster "${inputdir}/quota_price_hurdle_results_2022_03_04.ster"
global exponential_out "${outdir}/quota_price_exponential.txt"
global linear_out "${outdir}/quota_price_linear.txt"

est drop _all


/* read in linear model */
est use $input_ster, number(1)
est store linear


est restore linear
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving($linear_out) replace



/* read in exponential model */
est use $input_ster, number(3)
est store exponential



est restore exponential
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving($exponential_out) replace

/* read in exponential model */
/*
est use $input_ster, number(2)
est store exponential

est restore exponential
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving($exponential_out) replace



*/


