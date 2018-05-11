

# Function to calculate biomass-based reference points
# 
# type: type of reference point to calculate
#     
#     * RSPR: mean recruitment multiplied by SPR(Fmsy) or some proxy of
#             SPR at Fmsy
#             
#             par[1]: SPR level for Fmsy proxy (e.g., 0.35 for F35%)
#       
#     * dummy -- par is some scalar.





get_BBRP <- function(type, par, sel=NULL, waa=NULL, M=NULL, R=NULL,
                     mat=NULL, B, Rfun=mean){
  
  
  if(type == 'RSPR'){
    
    # get SPR at Fmax
    sprFmax <- get_perRecruit(type = 'SPR', par=par, sel=sel, waa=waa, 
                              M=M, mat=mat, nage=1000, nF=1000, nFrep=100)
    
    funR <- Rfun(R)
   
    B <- sprFmax$RPvalue * funR  #check ... seems wrong
    
    return(Bref = B)
    
  }else if(type == 'dummy'){
    
    # a placeholder for a ref point is all this is
    B <- max(B) * par
    
    return(Bref = B)
    
  }
  
  
}




