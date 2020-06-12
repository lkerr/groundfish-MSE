version 15.1

cd $inputdir
est use $post_input_ster, number(1)
est store postgillnetasc

est use $post_input_ster, number(2)
est store posttrawlasc


est use $pre_input_ster, number(1)
est store pregillnetasc

est use $pre_input_ster, number(2)
est store pretrawlasc


est restore postgillnetasc
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving($post_gillnet_out) replace



est restore posttrawlasc
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving($post_trawl_out) replace



est restore pregillnetasc
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving($pre_gillnet_out) replace



est restore pretrawlasc
mat b=e(b)
mat b=b'

mat colnames b="coefficient"
mat2txt, matrix(b) saving($pre_trawl_out) replace
estimates clear


