# A function to adjust the catch and landings multipliers for stocks that are not Allocated Multispecies.
# wt: the working_targeting dataset
# fh: fishery_holder, we will pull in a few things
  #stockarea_open, under_ACL, mults_allocated

##############################################################################
# Sets the landings multipliers=0 and catch_multipliers unchanged for all spstock2 that are non-allocated and that have underACL==FALSE
# This is a single-species management scenario , that assumes no "untargeting."
##############################################################################
#I'm purposefully leaving in the ec_type arguement for consistency with the function that zeros out me allocated multispecies.  But we're not using that arguement.


joint_adjust_others <- function(wt,fh,ec_type){
    no_alloc<-fh[mults_allocated==0]    
    closeds<-NULL

    # This if statement sets the landings multipliers=0 for all spstock2 that have underACL==FALSE
    closeds<-no_alloc[underACL==FALSE]$spstock2
    closed<-paste0("l_", closeds)
  
  if (length(closeds)==0){
      #do nothing
    } else {
        wt[, (closed):=0]
    }
    return(wt)
}

