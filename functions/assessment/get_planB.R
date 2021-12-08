#' @title Get Plan B Advice
#' @description Extract data for annual trends and apply Plan B approach to generate advice. Plan B approach adapted from: https://github.com/cmlegault/PlanBsmooth
#' 
#' @template global_stock
#' 
#' @return ???
#' 
#' @family managementProcedure stockAssess
#' 
#' @export

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
