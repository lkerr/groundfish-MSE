

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



