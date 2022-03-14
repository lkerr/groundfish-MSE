version 15.1

cd $inputdir

est use $input_ster, number(1)
est store gillnetasc

est use $input_ster, number(2)
est store trawlasc



est restore gillnetasc
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving($gillnet_out) replace



est restore trawlasc
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving($trawl_out) replace






