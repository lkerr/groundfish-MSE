#' @title Setup Economic Options
#' @description Pull economic options from mproc file for specified management procedure (may vary with the mproc lines).  
#' For example:
#' in the "validation" model runs, we use the "post" production regression, the  "pre" choice equations, post multipliers, prices.  
#' in the counterfactual model runs, we use the "pre" production regression, the  "pre" choice equations, post multipliers, prices.   
#' LandZero is unused
#' 
#' @template global_mproc
#' @template global_m
#' 
#' #' itemize{
#'   \item{econ_data_stub - A full file path to a folder containing annual data files for economic production data (labeled "####.Rda" for each year)}
#'   \item{production_vars - A vector of strings indicating names of production variables to use}
#'   \item{spstock_equation - A vector of strings indicating names used in species stock equation}
#'   \item{choice_equation - A vector of strings indicating names used in choice equation}
#'   \item{multipliers - A table??? of multipliers}
#'   \item{outputprices - A table??? of output prices}
#'   \item{inputprices - A table??? of input prices}
#' }
#' 
#' @family 
#' 
#' @export

setupEconType <- function(mproc, m){
  
  ##### Define independent variables in the targeting equation 
  ### If there are different targeting equations, you can set there up here, then use their suffix in the mproc file to use these new targeting equations
  ### example, using ChoicEqn=small in the mproc file and uncommenting the next two lines will be appropriate for a logit with just 3 RHS variables.
  
  ##spstock_equation_small=c("exp_rev_total", "fuelprice_distance")
  ##choice_equation_small=c("fuelprice_len")
  spstock_equation_pre <- c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
  choice_equation_pre <- c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")
  
  spstock_equation_post <- spstock_equation_pre
  choice_equation_post <- choice_equation_pre
  
  ##### Define independent variables in the Production equation 
  ### If there are different the equations, you can set there up here, then use their suffix in the mproc file to use these new targeting equations
  ### example, using ProdEqn=tiny in the mproc file and uncommenting the next  line will be regression with 2 RHS variables and no constant.
  # production_vars_tiny=c("log_crew","log_trip_days")
  
  production_vars_pre <- c("log_crew","log_trip_days","primary","secondary", "log_trawl_survey_weight","constant")
  production_vars_post <- c("log_crew","log_trip_days","primary","secondary", "log_trawl_survey_weight","log_sector_acl", "constant")
  
  
  ##### Subset mproc by economic variables of interest
  myvars<-c("LandZero", "CatchZero","EconType","EconName","EconData","MultiplierFile","OutputPriceFile","InputPriceFile","ProdEqn","ChoiceEqn")
  econtype <- mproc[m,]
  econtype <- econtype[myvars]
  
  # Read in Economic Production Data. "full_targeting" is large, so it makes sense to read in each econ_year as needed.
  econ_data_stub <- econtype$EconData
  
  ##### Setup econ variables based on specification in mproc & independent variable definitions above
  production_vars <- get(paste0("production_vars_",econtype$ProdEqn))
  spstock_equation <- get(paste0("spstock_equation_",econtype$ChoiceEqn))
  choice_equation <- get(paste0("choice_equation_",econtype$ChoiceEqn))
  
  # Read in relevant data files using provided filepaths 
  multipliers <- readRDS(file.path(econtype$MultiplierFile))
  outputprices <- readRDS(file.path(econtype$OutputPriceFile))
  inputprices <- readRDS(file.path(econtype$InputPriceFile))
  
  # Return
  econSetup$econ_data_stub <- econ_data_stub
  econSetup$production_vars <- production_vars
  econSetup$spstock_equation <- spstock_equation
  econSetup$choice_equation <- choice_equation
  econSetup$multipliers <- multipliers
  econSetup$outputprices <- outputprices
  econSetup$inputprices <- inputprices
  
  return(econSetup)
}
