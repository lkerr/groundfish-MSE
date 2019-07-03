global inputdir "C:\Users\Min-Yang.Lee\Documents\groundfish-MSE\data\data_raw\econ"
global outdir "C:\Users\Min-Yang.Lee\Documents\groundfish-MSE\data\data_raw\econ"



cd $inputdir
est use preCSnlogit.ster, number(1)

putexcel set nlogit_gillnet_pre_coefs.xls, replace
mat b=e(b)
mat b=b'
putexcel A2=matrix(b), rownames
putexcel A1="equation"
putexcel B1="variable"
putexcel C1="coefficient"

putexcel close
putexcel clear

mat colnames b="coefficient"
mat2txt, matrix(b) saving(nlogit_gillnet_pre_coefs.txt) replace
