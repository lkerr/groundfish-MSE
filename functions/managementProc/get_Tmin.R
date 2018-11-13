

# Function to get the minimum time for the population to have rebuilt
# to Bmsy. If the stock never achieves Bmsy then the function returns
# NA.
# 
# Bmsy: Bmsy for the stock
# 
# parpop: named list of population parameters. Passed directly to the
#         function get_proj(), so see that function for details.
# 
# Rlst: List of recruitment parameters. Passed directly to the function
#       get_proj(), so see that function for details.






get_Tmin <- function(Bmsy, parpop, Rlst = Rlst){

  # arbitrary large number to return for rebuilding time-scale if the
  # stock is not expected to be rebuilt within the specified time-
  # frame. Used locally within this function only -- actual return
  # if the median run is no rebuild is NA.
  largeNumber <- 1e6
  
  # Get 100 year projection at zero fishing mortality, and do it 50
  # times so you have a distribution
  proj <- t(sapply(1:50, function(x)
                  get_proj(parpop, F = 0, Rlst = Rlst, ny = 101)$SSB))
 

  # Determine which values were over the Bmsy threshold, and return the
  # minimum year for those events. If Bmsy is not acheived, return a 
  # large number.
    TminByYear <- sapply(1:nrow(proj), 
                         function(x){ wover <- which(proj[x,] > Bmsy)
                                      ifelse(length(wover) > 1,
                                             min(wover),
                                             largeNumber)
                         })
    
    # Use the median rebuilding year. Do this instead of something related
    # to a mean because the runs that do not return a value over the time-
    # frame were assigned an arbitrary large number.
    Tmin <- median(TminByYear)
    Tmin <- ifelse(Tmin == largeNumber, NA, Tmin)
    return(Tmin = Tmin)

}





# Testing

# parpop <- list(waa = c(6.162753e-05, 0.0004898678, 0.001349414, 0.002513996,
#                        0.003828504, 0.005166565, 0.006442675, 0.007607385,
#                        0.008637986, 0.00952959, 0.01028811, 0.01092526,
#                        0.01145527, 0.01189286, 0.01225201),
#                
#                sel = c(0.02983366, 0.1207014, 0.3131968, 0.544452, 0.7214171,
#                        0.8280724, 0.8879541, 0.9219868, 0.9421533, 0.9546855,
#                        0.9628277, 0.9683261, 0.9721615, 0.9749097, 0.9769222),
#                
#                M = c(0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,
#                      0.1, 0.1, 0.1, 0.1),
#                
#                mat = c(0.0752212, 0.4687695, 0.8567003, 0.9652281, 0.9896026,
#                        0.9961067, 0.9982356, 0.9990659, 0.9994395, 0.999628,
#                        0.9997323, 0.9997945, 0.9998337, 0.9998597, 0.9998776),
#                
#                R = c(19547356, 35078206, 27233625, 26270398, 22641519, 22641519,
#                      27410526, 25111002, 26008120, 33317613, 28620531, 26724153,
#                      26796403, 23308918, 30168548, 35896693, 28693501, 22591918,
#                      21674410, 29912927, 14576665, 11856781, 11856781, 15428706,
#                      18380227, 14586580, 14586580, 8690952, 11337731, 7811950),
#                
#                SSB = c(381157.9, 364810.9, 343017.4, 348422.1, 362937.9, 375785.5,
#                        394881.6, 400265.9, 402554.2, 408274.2, 406672.3, 424411.8,
#                        432210.6, 441509.5, 448223.4, 453963.2, 457103.6, 469232.4,
#                        474285.9, 473536.3, 460992.5, 461356.5, 448017.5, 428514.3,
#                        392707.3, 358871, 336044.9, 313091.9, 297577.9, 275644.1))
# 
# 
# 

# # Just a random initial value for this test -- code has been updated
# # so J1N is typically included in parpop.
# initN <- mean(parpop$R) * c(1, exp(-cumsum(parpop$M[-length(parpop$M)])))
# # for test need J1N to be a matrix.
# parpop$J1N <- matrix(initN, nrow=2, ncol=length(initN), byrow=TRUE)
# 
# # SSB
# Bmsy <- max(parpop$SSB) * 2.75
# 
# Rwt <- rep(1, length(parpop$R))
# 
# test <- get_Tmin(Bmsy=Bmsy, parpop, Rlst = list('stoch', Rwt))
# print(test)





