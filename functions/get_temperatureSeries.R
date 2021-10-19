#' @title Obtain temperature timeseries for simulations
#' @description One or more temperature timeseries from climate models are used to generate a timeseries for use in MSE simulations based on the specified temperature quantile.
#' 
#' @param cmip5Long A table with the following columns:
#' \itemize{
#'   \item{year - Numbers describing the year of the climate timeseries}
#'   \item{Model - Strings corresponding to different models}
#'   \item{Temperature - Numbers for temperature in degrees Celsius}
#'   \item{RCP - Numbers corresponding to the Representative Concentration Pathway (RCP)}
#' }
#' @param RCP A number = 8.5 ??? Is this needed as an input if cmip5Long only has one option for RCP? Maybe desirable in the event that other RCP values added in future?
#' @param Model A string specifying the climate model projection to use, no default.
#' \itemize{
#'   \item{"ACCESS1_0" - }
#'   \item{"ACCESS1_3" - }
#'   \item{"CAN_ESM2" - }
#'   \item{"CCSM4" - }
#'   \item{"CESM1_BGC" - }
#'   \item{"CESM1_CAM5" - }
#'   \item{"CMCC_CESM" - }
#'   \item{"CMCC_CM" - }
#'   \item{"CNRM_CM5" - }
#'   \item{"CSIRO_MK3_6_0" - }
#'   \item{"GFDL_CM3" - }
#'   \item{"GFDL_ESM2G" - }
#'   \item{"GFDL_ESM2M" - }
#'   \item{"GISS_E2_H" - }
#'   \item{"GISS_E2_R" - }
#'   \item{"HADGEM2_AO" - }
#'   \item{"HADGEM2_CC" - }
#'   \item{"HADGEM2_ES" - }
#'   \item{"INMCM4" - }
#'   \item{"IPSL_CM5A_LR" - }
#'   \item{"IPSL_CM5A_MR" - }
#'   \item{"IPSL_CM5B_LR" - }
#'   \item{"MIROC_ESM" - }
#'   \item{"MPI_ESM_LR" - }
#'   \item{"MPI_ESM_MR" - }
#'   \item{"NORESM1_M" - }
#'   \item{"NORESM1_ME" - }
#' }
#' @param quant A number between 0 and 1 specifying the desired temperature quantile
#' 
#' @return A table with the following columns:
#' \itemize{
#'   \item{year - Numbers describing the years of the temperature timeseries}
#'   \item{Temperature - Numbers describing temperature in degrees Celsius based on the selected climate models and quantile}
#' }
#' 
#' @family setup
#' 
#' @example 
#' get_temperatureSeries(cmip5Long, RCP = 8.5, Model = c("CAN_ESM2", "IPSL_CM5B_LR", "GFDL_ESM2G"), quant = 0.6)
#'

get_temperatureSeries <- function(cmip5Long, 
                                  RCP, 
                                  Model = NULL, 
                                  quant){
  
  # If no Model given assume all models are used
  if(is.null(Model)){
    Model <- unique(cmip5Long$Model)
  }
  
  # Subset based on RCP level
  csub <- subset(cmip5Long, RCP == RCP)
  
  # Get indices of models that are chosen and subset
  idx <- sapply(seq_along(Model), 
                FUN = function(x) which(csub$Model == Model[x]))
  csub2 <- csub[c(idx),]
  
  # Get quantile by year
  cquant <- aggregate(Temperature ~ year,
                      data = csub2,
                      FUN = quantile,
                      probs = quant)
  
  return(cquant)
}




# Test the function

# x <- get_temperatureSeries(cmip5Long, RCP = 8.5, 
#                            Model = c("CAN_ESM2", "IPSL_CM5B_LR", "GFDL_ESM2G"), 
#                            quant = 0.6)
# 
# y <- subset(cmip5Long, 
#             Model == "CAN_ESM2" | Model == "IPSL_CM5B_LR" | 
#             Model == "GFDL_ESM2G")
# 
# z <- aggregate(Temperature ~ year,
#                data = y,
#                FUN = quantile,
#                probs = 0.6)

# head(x)
## year Temperature
## 1 1901    16.23859
## 2 1902    16.04888
## 3 1903    16.27139
## 4 1904    15.86023
## 5 1905    16.16733
## 6 1906    16.13775

# head(z)
## year Temperature
## 1 1901    16.23859
## 2 1902    16.04888
## 3 1903    16.27139
## 4 1904    15.86023
## 5 1905    16.16733
## 6 1906    16.13775
