#' @title Update Annual Year Indexing
#' @description Update of within-year counters and indexing. These are needed/useful for the economic model.
#' 
#' @param yearitercounter An iteration counter for year y}
#' @param random_sim_draw A data.table containing the following indices as columns:
#' \itemize{
#'   \item{econ_replicate}
#'   \item{sim_year_idx}
#'   \item{cal_year}
#'   \item{manage_year_idx}
#'   \item{join_econbase_yr}
#'   \item{join_econbase_idx}
#'   \item{join_outputprice_idx}
#'   \item{join_inputprice_idx}
#'   \item{join_mult_idx}
#' }
#' @template global_y
#' @template global_fyear
#' @param savechunksize ???
#' 
#' @return A list containing the following:
#' \itemize{
#'   \item{yearitercounter - An updated iteration counter for year}
#'   \item{chunk_flag #??? need to save???}
#'   \item{econ_base_draw - A year for indexing}
#'   \item{econ_base_idx_draw}
#'   \item{econ_outputprice_idx_draw - Output price index}
#'   \item{econ_mult_idx_draw - ???}
#'   \item{econ_inputprice_idx_draw - Input price index}
#' }
#' 
#' @export

updateYearIndexing <- function(yearitercounter,
                               random_sim_draw,
                               y,
                               fyear,
                               savechunksize){
  
  yearitercounter <- yearitercounter+1
  ebd <- random_sim_draw[y-fyear+1,]
  chunk_flag <- yearitercounter %% savechunksize
  
  econ_base_draw <- ebd[,join_econbase_yr]
  econ_base_idx_draw <- ebd[,join_econbase_idx]
  econ_outputprice_idx_draw <- ebd[,join_outputprice_idx]
  econ_mult_idx_draw <- ebd[,join_mult_idx]
  econ_inputprice_idx_draw <- ebd[,join_inputprice_idx]
  
  # Return
  updateYearIndex <- NULL
  updateYearIndex$yearitercounter <- yearitercounter
  updateYearIndex$chunk_flag <- chunk_flag #??? need to save???
  updateYearIndex$econ_base_draw <- econ_base_draw 
  updateYearIndex$econ_base_idx_draw <- econ_base_idx_draw # Doesn't appear to be used in code
  updateYearIndex$econ_outputprice_idx_draw <- econ_outputprice_idx_draw
  updateYearIndex$econ_mult_idx_draw <- econ_mult_idx_draw
  updateYearIndex$econ_inputprice_idx_draw <- econ_inputprice_idx_draw
  
  return(updateYearIndex)
}
