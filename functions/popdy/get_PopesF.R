#' @title Get Popes F Approximation
#' @description Use catch data to calculate Popes approximation of fishing mortality (F)
#' 
#' @param yield A number for fishery yield in year y
#' @param naa A vector of numbers-at-age in year y
#' @param waa A vector of weight-at-age in year y
#' @param saa A vector of selectivity-at-age in year y
#' @param M Natural mortality (a vector at age??? a number???)
#' @param ra Reference ages to average F-at-age across
#' 
#' @return A vector of target F-at-age
#' 
#' @family operatingModel
#' 
#' @export

get_PopesF  <- function(yield, 
                        naa, 
                        waa, 
                        saa, 
                        M, 
                        ra){
  
  # 1.	Start with target yield (in biomass)
  # 2.	derive mean weight of catch in year y from OM, meanW=sumproduct(Na x Wa x Va)/sum(N x Va)
  # 3.	derive target catch (in numbers) C=Y/meanW
  # 4.	derive catch at age =C x ((Na x Va)/sumproduct(Na x Va))
  # 5.	derive survivors N(a+1,y+1)=(Na x exp(-Ma/2)-Ca) x exp(-Ma/2)
  # 6.	derive Fa=Ln(Na/Na,y+1)-Ma
  # 7.	use F at fully-selected age as target F.
  
  ## calcualte mean weight
  #calculate mean catch weight  
   mean_weight <- sum(naa * waa * saa) / sum(naa *saa)
  
  # calculate target catch
  targ_catch <- yield/mean_weight
  
  # calculate catch-at-age
  caa <- targ_catch * ((naa * saa)/sum(naa *saa))

  # calc Maa
  Maa <- rep(M, length(naa))
  
  # calculate survivors 
  surv <- (naa * exp(-Maa/2)- caa) * exp(-Maa/2)
  
  # fishing mortality-at-age 
  Faa <- log(naa/surv) - Maa 
 
  # calculate average Faa from reference ages 
  ref_F <- mean(Faa[ra])
  
  
  return(ref_F)
  
}
