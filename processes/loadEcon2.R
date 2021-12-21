#' @title Read in Economic Production Data. 
#' @description Read annual economic production data. "full_targeting" is large, so it makes sense to read in each econ_year as needed.
#' 
#' @param econ_data_stub A full file path to a folder containing annual data files for economic production data (labeled "####.Rda" for each year), no default. @seealso \code{\link{setupEconType}}
#' @param econ_base_draw A year for indexing, no default. @seealso \code{\link{updateYearIndexing}}/\code{\link{setupYearIndexing}}
#' @param econ_mult_idx_draw @seealso \code{\link{updateYearIndexing}}/\code{\link{setupYearIndexing}}
#' @param econ_outputprice_idx_draw Output price index, no default. @seealso \code{\link{updateYearIndexing}}/\code{\link{setupYearIndexing}}
#' @param econ_inputprice_idx_draw Input price index, no default. @seealso \code{\link{updateYearIndexing}}/\code{\link{setupYearIndexing}}
#' @param ggfishingyear ?????
#' 
#' @return A list containing the following:
#' \itemize{
#'   \item{wm}
#'   \item{wo}
#'   \item{wi}
#' }
#' 
#' @export

loadAnnualEconData <- function(econ_data_stub = NULL,
                               econ_base_draw = NULL,
                               econ_mult_idx_draw = NULL,
                               econ_outputprice_idx_draw = NULL,
                               econ_inputprice_idx_draw = NULL,
                               ggfishingyear){
  
  
  econdatafile <- paste0(econ_data_stub,econ_base_draw,".Rds") 
  targeting_dataset <- readRDS(file.path(econdatafile)) # !!! econ_data_stub now needs full file path
  
  wm <- multipliers[[econ_mult_idx_draw]]
  if ('gffishingyear' %in% colnames(wm)){
    wm[, gffishingyear:=NULL]
  }
  wo <- outputprices[[econ_outputprice_idx_draw]]
  if ('gffishingyear' %in% colnames(wo)){
    wo[, gffishingyear:=NULL]
  }
  wi <- inputprices[[econ_inputprice_idx_draw]]
  if ('gffishingyear' %in% colnames(wi)){
    wi[, gffishingyear:=NULL]
  }
  #temp for debugging
  #targeting_dataset$prhat<-targeting_dataset$pr
  
  #This would be a good place to adjust any indep variables in the targeting_dataset. (like forcing the fy dummy to a different value 
  
  # Return
  loadedData <- NULL
  loadedData$wm <- wm
  loadedData$wo <- wo
  loadedData$wi <- wi
  
  return(loadedData)
}
