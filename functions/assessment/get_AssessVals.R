


# match stock assessment data year with MSE year (pre-management period)
# replace calculated values 
# just fishing mortality for now - could add more if desired

get_AssessVals <- function(){
  replacement <- assess_vals$assessdat[assess_vals$assessdat$MSEyr == y,]
fish_mort <- replacement$F
rec <- replacement$R
nat_mort <- replacement$M


return(list(
 fish_mort = fish_mort,
 rec = rec,
 nat_mort = nat_mort,
 SSB = SSB))

}
