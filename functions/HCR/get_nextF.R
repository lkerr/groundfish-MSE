

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



get_nextF <- function(parmgt, parpop){
  
  
  # A general application of national standard 1 reference points. There
  # are different ways to grab the F reference point and the B reference
  # point and those will be implemented in get_FBRP
  if(tolower(parmgt$HCR) == 'ns1'){
    
    # For NS1 need F reference points and B reference points
    Fref <- get_FBRP(parmgt = parmgt, parpop = parpop)
    Bref <- get_BBRP(parmgt = parmgt, parpop = parpop, Rfun_lst=Rfun_BmsySim)
    F <- get_NS1HCR(parpop, Fmsy=Fref$RPvalue, Bmsy=Bref$RPvalue)['Fadvice']

  }else if(tolower(parmgt$HCR) == 'simplethresh'){
   
    Fref <- get_FBRP(parmgt = parmgt, parpop = parpop)
    Bref <- get_BBRP(parmgt = parmgt, parpop = parpop, Rfun_lst=Rfun_BmsySim)
    
    F <- ifelse(tail(parpop$B, 1) < Bref$RPvalue, 0, Fref$RPvalue)+1e-3
    
  }else{
    
    stop('get_nextF: type not recognized')
    
  }

  return(F)
}




