#' @title Get Terminal Relative Error
#' @description  Obtain relative error in terminal year for SCAA or ASAP stock assessments ???
#' 
#' @template global_stock
#'
#' @return 
#'
#' @family postprocess ???
#' 
#' @export

get_TermrelError <- function(stock){
 
  out <- within(stock, {
    #### Calculate terminal rel errors ####
    CN[y,] %*% waa[y,]
    if(mproc[m,'ASSESSCLASS'] == 'CAA' & y > fmyearIdx-1){
    }
    
    if(mproc[m,'ASSESSCLASS'] == 'ASAP' & y > fmyearIdx-1){
      relTermE_SSB <- get_relE(tail(res$SSB,1), SSB[y])
      relTermE_CW <- get_relE(res$catch.pred[length(res$catch.pred)], sumCW[y-1])
      relTermE_IN <- get_relE(tail(res$index.pred$ind01,1), sumIN[y-1])
      relTermE_R <- get_relE(tail(res$SR.resids$recruits,1), R[y-1])
      relTermE_F <- get_relE(tail(res$F.report,1), F_full[y-1])
    }
    
  })
  
  return(out) 
}
