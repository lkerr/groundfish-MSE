

# Run the planB assessment model (Legault)
# info can be found at:
# https://github.com/cmlegault/PlanBsmooth
# 
# 
# 


get_planB <- function(stock){
  
  out <- within(stock, {

    
    # Compile the data for the annual trend
    planBdata <- data.frame(Year = sty:(y-1), 
                            avg = get_dwindow(obs_sumIN, sty, y-1))
    
    planBest <- try(ApplyPlanBsmooth(dat = planBdata,
                                     od = 'results/',
                                     my.title = 'planB',
                                     terminal.year = NA,
                                     nyears = ncaayear,
                                     saveplots = FALSE,
                                     showplots = FALSE))

  })

  return(out)

}

