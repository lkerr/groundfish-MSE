


# N: vector of numbers at age in the most recent year
# 
# waa: vector of weights-at-age in the most recent year
# 
# M: vector of natural mortality-at-age
#        
# Rlst: list of recruitment parameters. Must be a two-element list. The first
#       element must indicate the type of recruitment function. Options are:
#        -- "rick" for Ricker recruitment
#        -- "bh" for Beverton-Holt recruitment
#        -- "stoch" for stochastic recruitment history
#       
#       
#       The second list element has to do with the parameters of the recruitment
#       function. These could be:
#       -- the parameters of a Ricker function
#       -- the parameters of a Beverton-Holt function
#       -- a vector of weights for each year. The recruitment history is
#          already input into the function (as part of parpop) 
#          so only the weights are necessary here. By default this is a vector 
#          of 1s, so all years are drawn with equal probability. To only draw 
#          from the last n years of the time series, set all other values in 
#          the vector to zero. For a weighted draw, assign weights to 
#          all values.




get_proj <- function(parpop, F, Rlst, ny){
  
  M <- parpop$M
  sel <- parpop$sel
  mat <- parpop$mat
  J1N <- tail(parpop$J1N, 1)
  R <- parpop$R
  waa <- parpop$waa
  
  # number of size classes
  nc <- length(J1N)
  
  projN <- matrix(NA, nrow=ny+1, ncol=nc)
  projN[1,] <- J1N
  
  for(y in 2:ny){
   
    # Regular age classes
      for(a in 2:(nc-1)){
        projN[y,a] <- projN[y-1,a-1] * exp(-F * sel[a-1] - M[a-1])
      }
    
    # plus group
    projN[y,nc] <- projN[y-1,nc-1] * exp(-F * sel[nc-1] - M[nc-1]) +
                   projN[y-1,nc] * exp(-F * sel[nc] - M[nc])
    
    # Recruits
      if(Rlst[[1]] == 'rick'){
        
        stop('get_proj: ricker not yet implemented')
        
      }else if(Rlst[[1]] == 'bh'){
        
        stop('get_proj: beverton-holt not yet implemented')
        
      }else if(Rlst[[1]] == 'stoch'){
        
        Rweights <- Rlst[[2]]
        
        if(length(Rweights) != length(R)){
          
          stop('get_proj: make sure the length of the weights vector is
                the same as the length of the recruitment vector')
          
        }
     
        Ry <- sample(R, size = 1, prob = Rweights)
      
      }else{
        
        stop('get_proj: check defenition of recruitment type')
        
      }
    
      projN[y,1] <- Ry

  }
  
  # Don't include the current year in the projections
  J1Npj <- projN[2:ny,]
  J1Bpj <- sweep(J1Npj, MARGIN=2, STATS=waa, FUN='*')
  SSBpj <- apply(J1Bpj, 1, sum)
  
  out <- list(J1N = J1Npj,
              SSB = SSBpj)
  
  return(out)

}





  

