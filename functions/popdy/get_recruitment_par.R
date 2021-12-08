#' @title Generate Stock-Recruit Parameters
#' @description Generate correlated random values for use in a stock-recruitment function. Before each iteration of the simulation, function called to generate parameters for use in iteration. 
#' Depending on the parameters that are given the behavior of the function will change. If no standard errors or covariance matrix is given, the function will pass the input parameters directly (i.e., there will be no stochasticity). Stochasticity can also be turned on or off directly with the 'stochastic' parameter. 
#' 
#' @param par A list including:
#' \itemize{
#'   \item{"type" - A string indicating the type of stock-recruit model to use, options include:}
#'   \itemize{
#'     \item{"constantMean" - ???}
#'     \item{"rickerlin" - ???}
#'     \item{"RITS" - for Ricker model}
#'     \item{"BHTS" - for Beverton-Holt}
#'   }
#'   \item{A vector of parameter names corresponding to the provided parameters ??? make sure names provided with possible parameters below}
#'   \item{A vector of parameters which may include:}
#'   \itemize{
#'     \item{A vector of standard errors}
#'     \item{A variance-covariance matrix}
#'     \item{A vector of lower bounds for parameters}
#'     \item{A vector of upper bounds for parameters}
#'   }
#' }
#' @param stochastic A boolean, if TRUE stochastic process applied. Default = FALSE.
#' 
#' @return 
#' 
#' @family operatingModel, population
#' 
#' @export

get_recruitment_par <- function(par, 
                                stochastic=TRUE){
  
  # if stochastic is FALSE then just return the given
  # parameter values with no uncertainty
  if(!stochastic){
    
    par1 <- list(type = par$type,
                 names = par$names,
                 par = par$par,
                 meanT = par$meanT)
    
    return(par1)
    
  }else{
  
    # if no parameter bounds are given, make them -Inf and Inf
    if(is.null(par$upper)){
      par$upper <- rep(Inf, length(par$names))
    }
    if(is.null(par$lower)){
      par$lower <- rep(-Inf, length(par$names))
    }
    
    # if no variance-covariance matrix is given, make one with
    # zeros (and a diagonal of the variance)
    if(is.null(par$cov)){
      if(is.null(par$se)){
        stop('get_recruitment_par: if is.null(par$cov) = TRUE 
             then must provide par$se')
      }else{
        par$cov <- matrix(0, nrow=length(par$names), 
                          ncol=length(par$names))
        diag(par$cov) <- par$se^2
      }  
    }
    
    # Generate random values for each of the parameters
    # c() makes the returned matrix into a vector
    par1 <- c(rtmvnorm(1, mean=par$par, sigma=par$cov,
                       lower=par$lower, upper=par$upper))
    names(par1) <- par$names
    
    return(list(type=par$type, 
                par=par1,
                meanT = par$meanT))
  
  }

}
