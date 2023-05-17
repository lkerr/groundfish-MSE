# Run the planB assessment model (Legault)
# info can be found at:
# https://github.com/cmlegault/PlanBsmooth

get_planB <- function(stock){
  out <- within(stock, {
    
    #start year
    styear <- fmyearIdx - ncaayear
    
     #end year
     if(mproc[m,'Lag'] == 'TRUE'){
       endyear <- y-2
     }
     else if(mproc[m,'Lag'] == 'FALSE'){
       endyear <- y-1
     }
     N_rows <- length(styear:endyear)
     
    # Compile the data for the annual trend
    planBdata <- data.frame(Year = styear:endyear, 
                            avg = sumIN[1:N_rows])
  
    
    planBest <- try(ApplyPlanBsmooth(dat = planBdata,
                                     od = 'results/',
                                     my.title = 'planB',
                                     terminal.year = NA,
                                     nyears = ncaayear,
                                     saveplots = FALSE,
                                     showplots = TRUE))

  })

  return(out)

}
