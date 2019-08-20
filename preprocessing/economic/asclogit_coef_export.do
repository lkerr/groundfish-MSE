global inputdir "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"
global outdir"/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/data/data_raw/econ"



cd $inputdir
est use postCSasclogit1.ster, number(1)
est store gillnetasc

est use postCSasclogit1.ster, number(2)
est store trawlasc
/*
putexcel set nlogit_gillnet_pre_coefs.xls, replace
mat b=e(b)
mat b=b'
putexcel A2=matrix(b), rownames
putexcel A1="equation"
putexcel B1="variable"
putexcel C1="coefficient"

putexcel close
putexcel clear
*/
est restore gillnetasc
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving(asclogit_gillnet_post_coefs.txt) replace



est restore trawlasc
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving(asclogit_trawl_post_coefs.txt) replace
