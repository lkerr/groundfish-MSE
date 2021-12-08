#' @title Generate Maturity 
#' @description Generate maturity expectations using method specified by type argument.
#' 
#' @param type A string indicating the type of selectivity function to implement, options include:
#' \itemize{
#'   \item{"knife" - Knife-edge selectivity (if laa > par, 1 else 0)}
#'   \item{"logistic" - L50 parameterization of logistic model (p = 1/(1 + exp(par[1]*(par[2] - laa))) )}
#'   \item{"input" - Use input vector of maturity-at-age}
#' }
#' @param par A vector of parameters used to calculate maturity-at-age, depend on specified type:
#' \itemize{
#'   \item{If type = "knife", par is  ???}
#'   \item{If type = "logistic", par is a vector of 2 parameters where the second is L50}
#'   \item{If type = "input", par is a vector of maturity-at-age to be reused}
#' }
#' @param laa A vector of length-at-age
#' @param tempY A value for temperature in year y, no default.
#' @template global_y
#' @template global_fmyearIdx
#' 
#' @return A vector ??? of maturity-at-age.
#' 
#' @family operatingModel, population
#' 
#' @export

# Function to return the maturity. Maturity functions
# are size-based so a length-at-age vector is necessary.
# 
# type: type of selectivity function. Available options are
#       *'knife'
#         if laa > par, 1; else 0
#       *'logistic'
#         follows L50 parameterization of logistic model
#         p = 1 / ( 1 + exp( par[1] * (par[2] - laa) ) )
#         where par[2] is L50
#       *'input'
#         give vector of maturity-at-age, must be same 
#         length as number of age classes
#
# par: vector of parameters to use in the function. See function
#      definitions in "type" for the length of the vector and
#      how the function is parameterized
#
# laa: length-at-age vector
# 
# tempY: value for temperature in year y


get_maturity <- function(type, 
                         par, 
                         laa, 
                         tempY=NULL,
                         y,
                         fmyearIdx){
  
  if(is.null(tempY)){
    tempY <- 0
  }
  
  if(type == 'logistic' && is.na(par[3])){
    par[3] <- 0
  }
  
  if(tolower(type) == 'knife'){
    
    if(length(par) != 1){
      stop('get_maturity: length of par must be 1 with knife
            option')
    }

    mat <- as.numeric(laa >= par)
  
  }
  if(tolower(type) == 'logistic'){

    # par[2] is L50
    # Looks like we can simply add an additional parameter here despite
    # the L50 version of the parameterization. Work this out on paper
    # and call v1 par[1]*par[2] and v2 -par[2] and go from there.
    mat <- 1 / (1 + exp(par[1] * (par[2] - laa) + par[3] * tempY))
    
  }
  
  if(tolower(type) == 'input'){
    mat <- par[1:length(par)]
  }
  
  if(tolower(type) == 'change'){
    if(y<fmyearIdx){
    mat <- par[1:9]
    }
    else{
   mat <- par[10:18]
    }
  }
  
  return(mat)
}





