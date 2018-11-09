


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




# Testing

parpop <- list(waa = c(6.162753e-05, 0.0004898678, 0.001349414, 0.002513996,
                       0.003828504, 0.005166565, 0.006442675, 0.007607385,
                       0.008637986, 0.00952959, 0.01028811, 0.01092526,
                       0.01145527, 0.01189286, 0.01225201),

               sel = c(0.02983366, 0.1207014, 0.3131968, 0.544452, 0.7214171,
                       0.8280724, 0.8879541, 0.9219868, 0.9421533, 0.9546855,
                       0.9628277, 0.9683261, 0.9721615, 0.9749097, 0.9769222),

               M = c(0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,
                     0.1, 0.1, 0.1, 0.1),

               mat = c(0.0752212, 0.4687695, 0.8567003, 0.9652281, 0.9896026,
                       0.9961067, 0.9982356, 0.9990659, 0.9994395, 0.999628,
                       0.9997323, 0.9997945, 0.9998337, 0.9998597, 0.9998776),

               R = c(19547356, 35078206, 27233625, 26270398, 22641519, 22641519,
                     27410526, 25111002, 26008120, 33317613, 28620531, 26724153,
                     26796403, 23308918, 30168548, 35896693, 28693501, 22591918,
                     21674410, 29912927, 14576665, 11856781, 11856781, 15428706,
                     18380227, 14586580, 14586580, 8690952, 11337731, 7811950),

               SSB = c(381157.9, 364810.9, 343017.4, 348422.1, 362937.9, 375785.5,
                     394881.6, 400265.9, 402554.2, 408274.2, 406672.3, 424411.8,
                     432210.6, 441509.5, 448223.4, 453963.2, 457103.6, 469232.4,
                     474285.9, 473536.3, 460992.5, 461356.5, 448017.5, 428514.3,
                     392707.3, 358871, 336044.9, 313091.9, 297577.9, 275644.1))




# Just a random initial value for this test
initN <- mean(parpop$R) * c(1, exp(-cumsum(parpop$M[-length(parpop$M)])))
# for test need J1N to be a matrix.
parpop$J1N <- matrix(initN, nrow=2, ncol=length(initN), byrow=TRUE)

Rwt <- rep(1, length(parpop$R))

test <- get_proj(parpop, F = 0.1, Rlst = list('stoch', Rwt), ny = 1000)

mean(test$SSB)
  
  
  
  

