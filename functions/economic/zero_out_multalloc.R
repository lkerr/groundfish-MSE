# A function to zero out the catch and/or landings multipliers for targeted and non_targeted Allocated Multispecies stocks.
##########################
# What am I going to do for unallocated multispeices stocks and non-multispecies stocks?
##########################
# wt: the working_targeting dataset
# fh: fishery_holder, we will pull in a few things
  #stockarea_open, under_ACL, mults_allocated
# ec_type: econtype taken from the mproc dataframe

##############################################################################
# Multi: For the "Multi" econ model, set the landings multipliers=0 for all spstock2 that have stockarea_open==FALSE
# This closely mimics how multispecies currently works.  In theory, the landings multipliers for these closed groundfish might be unchanged for some species. But, for the most part, in order to land regulated groundfish, you'll have to be in the catch share program. 
# There are no changes to the catch multipliers.  However, since vessels can't land groundfish from these stockareasthey shouldn't end up targeting.  If they did take a trip, they'd have to discard.
##############################################################################

##############################################################################
# SingleA :  This is a single-species management scenario.   
# sets the landings multipliers=0 for all spstock2 that have underACL==FALSE
#There are no changes to the catch multipliers for these species.  However, since vessels can't land the targeted groundfish from these stockareas, they shouldn't end up targeting.  If they did take a trip in that stockarea, they'd have to discard.
##############################################################################

##############################################################################
# SingleB: This is a single-species management scenario.   
# Sets the landings multipliers=0 and catch_multipliers=0 for all spstock2 that have underACL==FALSE
# This is a single-species management scenario , that assumes perfect "untargeting." If they did take a trip in that stockarea, it would not encounter any of the closed groundfish. 
##############################################################################

zero_out_multalloc <- function(wt,fh, ec_type){
    mul_alloc<-fh[mults_allocated==1]
    closeds<-NULL
    if (ec_type$EconType=="Multi"){
      # For the "Multi" econ model, set the landings multipliers=0 for all spstock2 that have stockarea_open==FALSE
      # Multi above.     
      
      closeds<-mul_alloc[stockarea_open==FALSE]$spstock2
      closed<-paste0("l_", closeds)
    } else if (ec_type$EconType=="Single" & ec_type$CatchZero=="FALSE"){
      # This if statement sets the landings multipliers=0 for all spstock2 that have underACL==FALSE
      closeds<-mul_alloc[underACL==FALSE]$spstock2
      closed<-paste0("l_", closeds)
    } else if (ec_type$EconType=="Single" & ec_type$CatchZero=="TRUE"){
      # This if statement sets the landings multipliers=0 and catch_multipliers=0 for all spstock2 that have underACL==FALSE
      closeds<-mul_alloc[underACL==FALSE]$spstock2
      closed<-c(paste0("l_", closeds), paste0("c_",closeds))
    } 
    
    if (length(closeds)==0){
      #do nothing
    } else {
        wt[, (closed):=0]
    }
    return(wt)
}

