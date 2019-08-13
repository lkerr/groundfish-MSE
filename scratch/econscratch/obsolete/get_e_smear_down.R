# July 8, 2019- ML believes this is unnecessary because 
# (a) we don't need to run the model at the daily level
# (b) we are going to back-calculate F at the end of the fishing year and then feed it through the get_popStep function


# functions to smear age classes if there are negatives.  
# Take the initial caa vector and the vector of negatives and zeros.  
# return a better guess for the caa vector. This can work on both weights and numbers


get_e_smear_down <- function(temp_caa,fix_neg_caa,position){
  temp_caa[position-1]=temp_caa[position-1]-fix_neg_caa[position]
  temp_caa[position]=temp_caa[position]+fix_neg_caa[position]
  return(temp_caa)
}
