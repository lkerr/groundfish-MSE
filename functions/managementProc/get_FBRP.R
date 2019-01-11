

# Function to calculate F-based reference points
# 
# parmgt: a 1-row data frame of management parameters. The operational
#         component of parmgt for this function is the (1-row) columns
#         "FREF_TYP" and "FREF_LEV". FREF_TYP indicates the type of model
#         that should be used to calculate the F reference point and
#         FREF_LEV is the associate F level (e.g., 0.4 for F40% if you are
#         using SPR or 0.1 for F0.1 if you are using YPR. Options for
#         FREF_TYP are:
#     
#     * YPR: yield-per-recruit-based reference point. See get_perRecruit.R.
#            Basically the parameters (par) are just the reference point 
#            level.
#     
#     * SPR: spawning potential ratio-based refence point. See 
#            get_perRecruit.R. Basically the parameters (par) are just the 
#            reference point level.
#            
#     * Mbased: natural mortality-based (data poor) option (see Gabriel and
#               Mace (1999), p.42. In some cases M or some factor of M has
#               been considered as a proxy for Fmsy.
#               
#     
# parpop: named ist of population parameters (vectors) needed for the 
#         simulation including selectivity (sel), weight-at-age (waa),
#         recruitment (R), maturity (mat) and natural mortality (M).
#         Natural mortality can be a vector or a scalar. Vectors have
#         one value per age class.





get_FBRP <- function(parmgt, parpop, parenv, Rfun_lst){
  
  
  if(parmgt$FREF_TYP == 'YPR' | parmgt$FREF_TYP == 'SPR'){
   
    F <- get_perRecruit(parmgt = parmgt, parpop = parpop)
   
    return(c(RPvalue = F))
    
  }else if(parmgt$FREF_TYP == 'FmsySim'){
    
    # Load in the recruitment function (recruitment function index is
    # found in the parmgt data frame but the actual functions are from
    # the list Rfun_BmsySim which is created in the processes folder.
    Rfun <- Rfun_BmsySim[[parmgt$RFUN_NM]]
    
    candF <- seq(from=0, to=2, by=0.025)
   
    Y <- sapply(1:length(candF), function(x){
                get_BmsySim(parmgt = parmgt, 
                            parpop = parpop, 
                            parenv = parenv, 
                            Rfun = Rfun, 
                            F_val=candF[x])$meanSumCW})
    
    Fmsy <- candF[which.max(Y)]
   
    # Warn if maximum yield did not occur within the range
    if(Fmsy %in% range(candF)){
      warning(paste('get_FBRP: maximum yield occurs at endpoint of',
                    'candidate F values'))
    }
    
    return(c(RPvalue = Fmsy))
    
  }else if(parmgt$FREF_TYP == 'Fmed'){
    
    slp <- get_replacement(parpop = parpop, parmgt = parmgt)
    pmtemp <- list(FREF_TYP = 'SSBR')
    ssbrGrid <- get_perRecruit(parmgt = pmtemp, parpop = parpop)$PRgrid
    F <- get_fmed(parpop = parpop, rep_slp = slp, ssbrGrid = ssbrGrid)
    
    return(list(RPvalue = F))
    
  }else{
    
    stop('get_FBRP: parmgt FREF_TYP not recognized')
    
  }
  
  
}





