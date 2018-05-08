

# Function to calculate biomass-based reference points
# 
# type: type of reference point to calculate
#     
#     * RSPR: mean recruitment multiplied by SPR(Fmsy) or some proxy of
#             SPR at Fmsy
#             
#             par[1]: SPR level for Fmsy proxy (e.g., 0.35 for F35%)
#       
#     * 





get_BBRP <- function(type, par, sel=NULL, waa=NULL, M=NULL, R=NULL,
                     mat=NULL, Rfun=mean){
  
  
  if(type == 'RSPR'){
    
    # get SPR at Fmax
    sprFmax <- get_perRecruit(type = 'SPR', par=par, sel=sel, waa=waa, 
                              M=M, mat=mat, nage=1000, nF=1000, nFrep=100)
    
    meanR <- Rfun(R)
   
    B <- sprFmax$RPvalue * par
    
    return(Bref = B)
    
  }else if(type == 'other'){
    
    return(NA)
    
  }
  
  
}




