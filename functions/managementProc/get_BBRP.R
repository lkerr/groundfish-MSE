

# Function to calculate biomass-based reference points
# 
# parmgt: a 1-row data frame of management parameters. The operational
#         component of parmgt for this function are the (1-row) columns
#         "BREF_TYP" and "BREF_LEV". BREF_TYP refers to the type of biomass-
#         based reference point you want to use and BREF_LEV refers to
#         an associated level for that reference point. Options are:
#     
#     * RSSBR: mean recruitment multiplied by SPR(Fmsy) or some proxy of
#             SPR at Fmsy
#             
#             par[1]: SPR level for Fmsy proxy (e.g., 0.35 for F35%)
#       
#     * dummy -- par is some scalar.
#     
# parpop: list of population parameters needed to calculate the biomass-
#         based reference point. See specific functions, e.g.
#           get_perRecruit()
#           get_BmsySim
#         to see what needs to be included in the list.





get_BBRP <- function(parmgt, parpop, Rfun_lst){

  
  if(parmgt$BREF_TYP == 'RSSBR'){
    
    # get Fmax proxy
    Fprox <- get_FBRP(parmgt = parmgt, parpop = parpop)
    
    parmgt1 <- list(FREF_LEV=Fprox$RPvalue, FREF_TYP='SSBR')
    
    ssbrFmax <- get_perRecruit(parmgt=parmgt1, parpop=parpop, 
                              nage=1000, nF=1000, nFrep=100)
    
    # Load in the recruitment function (recruitment function index is
    # found in the parmgt data frame but the actual functions are from
    # the list Rfun_BmsySim which is created in the processes folder.
    Rfun <- Rfun_lst[[parmgt$RFUN_NM]]
    
    funR <- Rfun(parpop$R)
   
    B <- ssbrFmax$SSBvalue * funR

    return(list(RPvalue = B))
    
  }else if(parmgt$BREF_TYP == 'SIM'){
    
    # Load in the recruitment function (recruitment function index is
    # found in the parmgt data frame but the actual functions are from
    # the list Rfun_BmsySim which is created in the processes folder.
    Rfun <- Rfun_BmsySim[[parmgt$RFUN_NM]]
    
    # get SPR at Fmax
    sprFmax <- get_perRecruit(parmgt=mproc[m,], parpop=parpop,
                              nage=1000, nF=1000, nFrep=100)
    
    B <- get_BmsySim(parmgt, parpop, Rfun = Rfun, 
                     F_val=sprFmax$RPvalue)$SSBvalue

    return(list(RPvalue = B))
    
  }
  
  
}




