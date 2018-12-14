

# The application of harvest control rules
#
# parmgt: a 1-row data frame of management parameters. The operational
#         component of parmgt for this function is the (1-row) column
#         "HCR". Options are:
#  
#           * "ns1": based on national standard 1 precautionary approach, this is
#               the classic harvest control rule that increases linearly and 
#               then reaches an asymptote at [Bmsy,Fmsy]
#        
#           * "simpleThresh": a simple threshold model where fishing is entirely
#                        cut off when the population is overfished 
#                        (i.e., B<Bmsy)
#                        
# parpop: named ist of population parameters (vectors) needed for the 
#         simulation including selectivity (sel), weight-at-age (waa),
#         recruitment (R), maturity (mat) and natural mortality (M).
#         Natural mortality can be a vector or a scalar. Vectors have
#         one value per age class.
#         
# Rlast: a vector of length 2 representing the Fmsy and Bmsy reference points
#        that were used in the previous year of the simulation. The reason
#        for this is so you can evaluate management procedures that only
#        update reference points once every N number of years.
#        
# evalRP: True/False variable indicating whether reference points should
#         be evaluated at all -- if not then just use RPlast. Function
#         could be simplified a little to combine RPlast and evalRP but
#         it is pretty clear this way at least.


get_nextF <- function(parmgt, parpop, parenv, RPlast, evalRP){
  
  
  # A general application of national standard 1 reference points. There
  # are different ways to grab the F reference point and the B reference
  # point and those will be implemented in get_FBRP
  
  if(parmgt$ASSESSCLASS == 'CAA'){
    Fref <- get_FBRP(parmgt = parmgt, parpop = parpop)
    Bref <- get_BBRP(parmgt = parmgt, parpop = parpop, 
                     parenv = parenv, Rfun_lst=Rfun_BmsySim)
   
    if(evalRP){
      FrefRPvalue <- Fref$RPvalue
      BrefRPvalue <- Bref$RPvalue
    }else{
      FrefRPvalue <- RPlast[1]
      BrefRPvalue <- RPlast[2]
    }
    
    # Determine whether the population is overfished and whether 
    # overfishing is occurring

    overfished <- ifelse(tail(parpop$SSBhat,1) < BrefRPvalue, 1, 0)
    
    if(tolower(parmgt$HCR) == 'ns1'){
     
      F <- get_NS1HCR(parpop, Fmsy=FrefRPvalue, Bmsy=BrefRPvalue)['Fadvice']
  
  
    }else if(tolower(parmgt$HCR) == 'simplethresh'){
     
      
      
      # added small value to F because F = 0 causes some estimation errors
      F <- ifelse(tail(parpop$SSBhat, 1) < BrefRPvalue, 0, FrefRPvalue)+1e-4
      
    }else{
      
      stop('get_nextF: type not recognized')
      
    }
  
    out <- list(F=F, RPs=c(FrefRPvalue, BrefRPvalue), OFdStatus=overfished)
    
  }else if(parmgt$ASSESSCLASS == 'PLANB'){
    
    # Find the recommended level for catch in weight
    CWrec <- tail(parpop$obs_sumCW, 1) * parpop$mult
    
    #### NEXT MIGRATE THE WEIGHT TO A FISHING MORTALITY
    #### you know what the selectivity is going to be 
    #### (use the real one here) and you know what the weight is
    #### going to be (use the real one) so drive the F as hard as
    #### required in each of the age classes until you land on
    #### the desired catch biomass.
    
    # Calculate what the corresponding true F is that matches with
    # the actual biomass-at-age in the current year
    trueF <- getF(x = CWrec,
                  Nv = parpop$Ntrue_y, 
                  slxCv = parpop$slxCtrue_y, 
                  M = parpop$Mtrue_y, 
                  waav = parpop$waatrue_y)
    
    out <- list(F = trueF, RPs = c(NA, NA), OFdStatus=NA)
    
  }else{
    
    stop('Assessment class not recognized')
    
  }
  
  return(out)
}




