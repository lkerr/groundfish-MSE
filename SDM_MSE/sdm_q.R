#' @title 
#' @description  Format SDM output for reference in SDM_sims catchability adjustment
#' 
#' @param METRIC A string indicating the SDM metric (result) to pull, no default. Options:
#' \itemize{
#'   \item{"COG" - Center of gravity}
#'   \item{"EAO" - Effective area occupied}
#'   \item{"relAbund" - Relative abundance}
#' }
#' @param SEASON A string indicating season, no default. Options:
#' \itemize{
#'   \item{"Spring"}
#'   \item{"Summer"}
#'   \item{"Fall"}
#' }
#' @param SCENARIO A string indicating the climate scenario to use for adjustments, no default. Options:
#' \itemize{
#'   \item{"SSP5_85"}
#'   \item{"SSP1_26"}
#' }
#' @param YEAR_RANGE A range of years to pull (need depends on MSE settings), currently defaults to maximum available in file (1985-2100).
#' @param REGION A string indicating what region this data represents, only required if METRIC == "relAbund", no default. Options:
#' \itemize{
#'   \item{"All" - Whole Northeast US}
#'   \item{"GB" - Georges Bank region}
#'   \item{"GoM" - Gulf of Maine region}
#' }

# NOTE: relAbund may be a bad catchability covariate since it runs the risk of double counting index data within the assessment model, but we can revisit this

sdm_q <- function(METRIC = NULL,
                  SEASON = NULL,
                  SCENARIO = NULL,
                  YEAR_RANGE = NULL,
                  REGION = NULL){
  
  if(METRIC == "COG"){
    metric <- read.csv(here::here("SDM_MSE", "MSE_COG_TS.csv")) %>%
      dplyr::filter(Season == SEASON) %>% 
      dplyr::filter(ClimScenario == SCENARIO) %>% 
      mutate(metricMean = Lat_COG_Mean) %>% 
      mutate(timeseriesMean = mean(metricMean), anomaly = metricMean - timeseriesMean, percentChange = anomaly/timeseriesMean) %>% # Calculate anomaly from time series mean and percent change relative to this mean
      mutate(SE = (Lat_COG_90thPercentile- Lat_COG_10thPercentile)/3.29) # Calculate SE based on 10th and 90th percentiles
  } else if(METRIC == "EAO"){
    
  } else if(METRIC == "relAbund"){
    metric <- read.csv(here::here("SDM_MSE", "MSE_RelBiomassIndex_TS.csv")) %>%
      dplyr::filter(Season == SEASON) %>%
      dplyr::filter(ClimScenario == SCENARIO) %>%
      dplyr::filter(Region == REGION) %>%
      mutate(metricMean = "Biomass_Index_Mean") %>%
      mutate(timeseriesMean = mean(metricMean), anomaly = metricMean - timeseriesMean, percentChange = anomaly/timeseriesMean) %>% # Calculate anomaly from time series mean and percent change relative to this mean
      mutate(SE = (Biomass_Index_90thPercentile-Biomass_Index_10thPercentile)/3.29) # Calculate SE based on 10th and 90th percentiles
  }
  
  if(is.null(YEAR_RANGE) == FALSE){ # If year range provided also filter years, otherwise all data retained (1985-2100)
    metric <- metric %>% 
      dplyr::filter(Year >= YEAR_RANGE[1] & Year <= YEAR_RANGE[length(YEAR_RANGE)])
  }
  
  return(metric)
}

 