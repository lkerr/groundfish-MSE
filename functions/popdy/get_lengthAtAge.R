#' @title Calculate lengths-at-age
#' @description Calculate lengths-at-age using the method specified by type.
#' 
#' @param type A string indicating the method used to calculate lengths-at-age, options include:
#' \itemize{
#'   \item{"vonB" - Use von Bertalanffy equation}
#' }
#' @param par A vector of parameters used to calculate lengths-at-age, dependent on selected type:
#' \itemize{
#'   \item{If type = "vonB", par is a named vector of two parameters 'beta1' and 'beta2'}
#' }
#' @param ages A vector of ages in the model
#' @template Tanom
#' 
#' @return 
#' 
#' @family 
#' 
#' @export

get_lengthAtAge <- function(type, 
                            par, 
                            ages, 
                            Tanom=NULL){
  
  if(tolower(type) == 'vonb'){
    
    # if any of the par parameters are NA (i.e., are unused temperature
    # effects) then set them to zero so they will not impact growth at all.
    if(is.na(par['beta1'])){
      par['beta1'] <- 0
    }
    if(is.na(par['beta2'])){
      par['beta2'] <- 0
    }
    
    if(is.null(Tanom)){
      Tanom <- 0
    }
    
    laa <- (par['Linf'] + par['beta1'] * Tanom) * 
           (1 - exp(-(par['K'] + par['beta2'] * Tanom) * (ages - par['t0'])))
  
  }else{
    
    stop('length-at-age type not recognized')
    
  }
  
  return(laa)
}
