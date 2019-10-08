


# match stock assessment data year with MSE year (pre-management period)
# replace calculated values 
# just fishing mortality for now - could add more if desired

get_AssessVals <- function(stock){
  replacement <- assess_vals$assessdat[assess_vals$assessdat$MSEyr == y,]
fish_mort <- replacement$F

return(list(
 fish_mort = fish_mort))

}
