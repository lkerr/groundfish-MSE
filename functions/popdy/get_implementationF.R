#' @title Get Implementation F
#' @description Calculate Implementation Fishing Mortality Rate (F)
#' 
#' @param type A string specifying the method to calculate initial implementation F, options are:
#' \itemize{
#'   \item{"advicenoError" - Use full F advice}
#'   \item{"adviceWithError" - Use full F advice with added error}
#'   \item{"advicewithcatchbias" - Generate catch based on full F, add catch bias, backcalculate and return final F required to obtain biased catch}
#' }
#' @template global_stock
#' @template global_y
#' 
#' @return ??? Not specified
#' 
#' @family 
#' 
#' @export

get_implementationF <- function(type, 
                                stock, 
                                y){

  within(stock, {
    
    if(type == 'advicenoError'){
      
      F_full[y]<- F_fullAdvice[y]
      
    }
    if(type == 'adviceWithError'){
      
      # Borrowed error_idx function from survey function bank
      Fimpl <- F_fullAdvice[y] + F_fullAdvice[y]*ie_bias
      F_full[y] <- get_error_idx(type = ie_typ,
                                 idx = Fimpl,
                                 par = ie_F)
    }
    
    else if(type == 'advicewithcatchbias'){
      # add implimentation bias to catch, need to convert from F to catch, back to F
      # get catch in numbers using the Baranov catch equation from advised F
      
      CN_temp[y,] <- get_catch(F_full=F_full[y], M=natM[y],
                               N=J1N[y,], selC=slxC[y,]) + 1e-3
      
      # Figure out the advised catch weight-at-age
      codCW[y,] <- CN_temp[y,] *  waa[y,]
      
      # add bias to sum catch weight
      
      codCW2[y] <- sum(codCW[y,]) + (sum(codCW[y,]) * C_mult)
      
      if(Change_point2==TRUE && yrs[y]>=Change_point_yr){
        codCW2[y] <- sum(codCW[y,])
      }
      
      if(Change_point3==TRUE && yrs[y]>=Change_point_yr1){
        codCW2[y] <- sum(codCW[y,]) + (sum(codCW[y,]) * 0.5)
      }
      
      if(Change_point3==TRUE && yrs[y]>=Change_point_yr2){
        codCW2[y] <-sum(codCW[y,])
      }
      
      # Determine what the fishing mortality would have to be to get
      # that biased catch level (convert biased catch back to F).
      # Update codGOM fully selected fishing mortality to that value.
      
      # ST method using solver;
      F_full[y] <- get_F(x = c(codCW2[y]),
                         Nv = J1N[y,],
                         slxCv = slxC[y,],
                         M = natM[y],
                         waav = waa[y,])
    }
    
    # Using Pope's approximation;
    # codCW2 needs to be converted to at-age to use
    #
    # F_full[y] <- get_PopesF(yield = c(codCW2[y,]),
    #                                      naa = J1N[y,],
    #                                      waa = waa[y,],
    #                                      saa = slxC[y,],
    #                                      M = natM[y],
    #                                      ra = c(8))
    
    else{
      
      stop('get_implementationF: type not recognized')
      
    }
    
  })
  
}
