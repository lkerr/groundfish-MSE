#' @title Calculate Selectivity-At-Age
#' @description Calculate and return selectivity-at-age. Selectivity functions are size-based so length-at-age vector required for calculation. 
#' 
#' @param type A string indicating the method used to generate selectivity-at-age:
#' \itemize{
#'   \item{"logistic" - Logistic selectivity is implemented}
#'   \item{"const" - Constant selectivity is implemented}
#'   \item{"input" - Use selectivity-at-age provided in par}
#' }
#' @param par A vector of parameters used to calculate selectivity-at-age, dependent on selected type:
#' \itemize{
#'   \item{If type = "logistic", par is a vector of two parameters describing the logistic relationship}
#'   \item{If type = "const", par is a single parameter to fix selectivity at a single value (i.e. the input parameter is returned)}
#'   \item{If type = "input", par is a vector of selectivity-at-age}
#' }
#' @param laa A length-at-age matrix, no default. ??? Matrix or vector, existing documentation inconsistent
#' 
#' @return 
#' 
#' @family operatingModel, population
#' 
#' @export

get_slx <- function(type, 
                    par, 
                    laa=NULL){
  
  if(tolower(type) == 'logistic'){
  
     slx <- 1 / (1 + exp(par[1] - par[2] * laa))
  
  }else if(tolower(type) == 'const'){
    
    if(par[1] < 0 || par[1] > 1){
      stop('constant selectivity parameters need to be between zero and 1')
    }
    
    slx <- par[1]
    
  }else if(tolower(type) == 'input'){
     if (any(par < 0 | par > 1)){
       stop('input selectivity parameters need to be between zero and 1')
     }
    
    slx <- par[1:length(par)]
  }
  
  return(slx)
  
}
