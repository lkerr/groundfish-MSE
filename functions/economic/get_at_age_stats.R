# Function to calculate catch-at-age, weight of the catch-at-age, and NAA that survive the pulse of fishing.   based on available numbers, selectivity, and catch.   This "inverts" the get_catch.R function.  It also error-handles for catch-at-age greater than NAA. Since we need to calculate weights and survivors to do this, we might as well return them as well.
# You've got a bunch of debug comments in here
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
  # survivor_numbers = NAA of the survivors
  # survivors = vector of weight of the survivors




#Notes
# Ignoring natural mortality, we have
# kilograms_at_age \cdot caa = catch 
# caa = selC*F_full*N
#
# waa \cdot [ selC*F_full*N]=catch
# waa \cdot [ selC*N] * F_full=catch
# waa \cdot [selcC*N] 


get_at_age_stats <- function(catch_kg, NAA, kilograms_at_age,selC){
  works<-as.logical("TRUE")
  
   size_NAA<-length(NAA)
  
  #check to see if you've caught everything
   #yes, these are transposed. don't ask.
  total_weight<-NAA%*%kilograms_at_age
  if (catch_kg>=total_weight){
   print("congrats you caught it all") 
    mycaa<-t(NAA)
    mycaa_weights<-t(NAA)*kilograms_at_age
    survivor_nums<-0*mycaa
    next_weights<-0*mycaa
    } else{
  
  
  
  
  #Note, I tested doing this in one line. It's not faster
  oneu<-selC*NAA
  oneuW<-t(kilograms_at_age)%*% oneu
  scaleup<-catch_kg/oneuW
  mycaa<-scaleup %*% oneu
  # scaleup is like a pseudo F-full. It ignores natural mortality rates. I don't think we want to report this.  
  
  # Error handle #
  # If any elements of caa are greater than the corresponding element of N
  
  #compute vector of aggregate weight by age class.
  NAA_weights<-NAA*kilograms_at_age
  mycaa_weights<-mycaa*kilograms_at_age
  next_weights<-NAA_weights - mycaa_weights
  
  
  
  # A while would be more elegant, but it might end up stuck (you'd need a pretty awful age structure for that).  
  # instead, loop a "small number of times". Then write something to hack/deal with a bad age structure?
  
  for (iter in 1:6) {
    print(paste0("part 1 iteration number ", iter))
    
  if(any(next_weights<0)){
    print(paste0("part 2 iteration number ", iter))
    
    fix_weight<-next_weights
    fix_weight[fix_weight>=0]<-0

    #deal with the first age class and last age class
    lc<-1
    if(fix_weight[lc] <0)  {
      mycaa_weights<-get_e_smear_up(mycaa_weights,fix_weight,lc) 
    }
    
    lc<-size_NAA
    if(fix_weight[lc] <0)  {
      mycaa_weights<-get_e_smear_down(mycaa_weights,fix_weight,lc) 
    }
    
    #deal with the age classes that are in the middle.
    # if you were better at R, you could write this to facilitate an lapply. But you're not.
    for (lc in 2:(size_NAA-1)) {
      if(fix_weight[lc] <0)  {
        if (next_weights[lc-1]>0 & next_weights[lc+1]>0){
          mycaa_weights<-get_e_smear_both(mycaa_weights,fix_weight,lc) 
          print(paste0("smearing both lc=",lc) )
        }
        if (next_weights[lc-1]>0 & next_weights[lc+1]<=0){
          mycaa_weights<-get_e_smear_down(mycaa_weights,fix_weight,lc) 
          print(paste0("smearing down lc=",lc) )
        }
        if (next_weights[lc-1]<=0 & next_weights[lc+1]>0){
          mycaa_weights<-get_e_smear_up(mycaa_weights,fix_weight,lc)
          print(paste0("smearing up lc=",lc) )
        }
      }else {
          print("No change")
        }    
}
    #To re-loop, you just need to compute next_weights.  NAA_weights doesn't change. mycaa and mycaa_weights are computed inside here.
    next_weights<-NAA_weights-(mycaa_weights)
    }
    else{
      break      
      #Obviously, dont' step through if all age classes are non-negative
        }
  }
  
    #Flag things that broke.  Set the weight in that age class to zero. 
  if(any(next_weights<0)){
    works<-as.logical("FALSE")
    next_weights[next_weights<=0]<-0
  }
  

  #Convert mycaa_weights to mycaa and compute survivor numbers
  mycaa<-mycaa_weights/kgatage
  survivor_nums<-NAA-mycaa
    }
  
  outList <- list("caa" = mycaa, "weight_caa" = mycaa_weights, "survivor_weights"=next_weights,"survivor_numbers"=survivor_nums, "worked"=works)
  return(outList)
  
}





