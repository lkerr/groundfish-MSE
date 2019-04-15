# functions to smear age classes if there is a negative age class  
# Take the initial caa vector and the vector of negatives and zeros.  
# return a better guess for the caa vector. This can work on both weights and numbers

get_e_smear_both <- function(temp_caa,fix_neg_caa,position){
  temp_caa[position-1]=temp_caa[position-1]-fix_neg_caa[position]/2
  temp_caa[position+1]=temp_caa[position+1]-fix_neg_caa[position]/2
  temp_caa[position]=temp_caa[position]+fix_neg_caa[position]
  return(temp_caa)
}