# Function to calculate catch-at-age, weight of the catch-at-age, and NAA that survive the pulse of fishing.   based on available numbers, selectivity, and catch.   This "inverts" the get_catch.R function.  It also error-handles for catch-at-age greater than NAA. Since we need to calculate weights and survivors to do this, we might as well return them as well
# 
# INPUTS:
# catch (1x1): scalar of removals. catch and waa should be in the same units (kilograms) 
# N (1xK): vector of Numbers by age (after growth and recruitment)
# kilograms_at_age (1xK): vector of weights at age, in kilograms. 
# selC (1xK): vector of fishery selectivity by age

# Outputs
# outList is a list containing:
# caa (1xK): vector of catch-at-age.
# weight_caa 
# survivors = NAA of the survivors
# scaleup is like a pseudo F-full. It ignores natural mortality rates. I don't think we want to report this.  

#Notes
# Ignoring natural mortality, we have
# kilograms_at_age \cdot caa = catch 
# caa = selC*F_full*N
#
# waa \cdot [ selC*F_full*N]=catch
# waa \cdot [ selC*N] * F_full=catch
# waa \cdot [selcC*N] 


get_at_age_stats <- function(catch_kg, NAA, kilograms_at_age,selC){
  
  #Note, I tested doing this in one line. It's not faster
  oneu<-selC*NAA
  oneuW<-t(kilograms_at_age)%*% oneu
  scaleup<-catch_kg/oneuW
  mycaa<-scaleup %*% oneu
  
  # Error handle #
  # If any elements of caa are greater than the corresponding element of N
  NAA_weights<-NAA*kilograms_at_age
  mycaa_weights<-mycaa*kilograms_at_age
  next_weights<-NAA_weights - mycaa_weights
  
  
  # You shold wrap a while around this.  But it might end up stuck (you'd need a pretty awful age structure for that).   # instead, loop a "small number of times". Then write something to hack/deal with a bad draw?
  
  
  if(any(next_weights<0)){
    print("fixing negative")
    fix_weight<-next_weights
    fix_weight[fix_weight>=0]<-0
    fix_counts<-fix_weight/kilograms_at_age
    end<-length(NAA)
    
    #### fancy way
    
    
    #deal with the first age class and last age class
    lc<-1
    if(fix_weight[lc] <0)  {
      mycaa_weights<-e_smear_up(mycaa_weights,fix_weight,lc) 
      mycaa<-e_smear_up(mycaa,fix_counts,lc) 
    }
    
    lc<-end
    if(fix_weight[lc] <0)  {
      mycaa_weights<-e_smear_down(mycaa_weights,fix_weight,lc) 
      mycaa<-e_smear_down(mycaa,fix_counts,lc) 
    }
    
    #deal with the age classes that are in the middle.
    # if you were better at R, you could write this to facilitate an lapply. But you're not.
    for (lc in 2:(end-1)) {
      if(fix_weight[lc] <0)  {
        if (NAA_weights[lc-1]>0 & NAA_weights[lc+1]>0){
          mycaa_weights<-e_smear_both(mycaa_weights,fix_weight,lc) 
          mycaa<-e_smear_both(mycaa,fix_counts,lc) 
        }
        if (NAA_weights[lc-1]>0 & NAA_weights[lc+1]<=0){
          mycaa_weights<-e_smear_down(mycaa_weights,fix_weight,lc) 
          mycaa<-e_smear_down(mycaa,fix_counts,lc) 
        }
        if (NAA_weights[lc-1]<=0 & NAA_weights[lc+1]>0){
          mycaa_weights<-e_smear_up(mycaa_weights,fix_weight,lc) 
          mycaa<-e_smear_down(mycaa,fix_counts,lc) 
        }
      }
    }
    
    next_weights<-NAA_weights-mycaa_weights

  }
  
  
  
  
  survivor_weights<-NAA_weights-mycaa_weights
  survivor_nums<-NAA-mycaa
  
  outList <- list("caa" = mycaa, "weight_caa" = mycaa_weights, "survivor_weights"=survivor_weights,"survivor_numbers"=survivor_nums)
  return(outList)
  
}



#Note, I tested 





