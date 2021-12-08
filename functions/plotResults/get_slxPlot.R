#' @title Plot Selectivity
#' @description Generate a plot of selectivity
#' 
#' @param ages A vector of ages
#' @param type A string of "age" or "length" that governs whether the output selectivity is age- or length-based. (Selectivity always length-based ... this just governs what the plot looks like because you may want to compare to age-based selectivities in actual assessments.) 
#' @param laa_typ A string describing the type of length-at-age model (@seealso get_lengthAtAge), obtained from "stock" object
#' @param laa_par A vector of length-at-age parameters (@seealso get_lengthAtAge), obtained from "stock" object
#' @param selC_typ A string describing the type of selectivity function (@seealso get_slx), obtained from "stock" object
#' @param selC_par A vector of selectivity-at-age parameters (@seealso get_slx), obtained from "stock" object
#' @param TAnom A vector of temperature anomolies to use in the length-at-age function
#' 
#' @return A plot of selectivity
#' 
#' @family postprocess
#' 
#' @export

get_slxPlot <- function(ages, type, laa_typ, laa_par, 
                        selC_typ, selCpar, TAnom){
 
  
  if(!type %in% c('length', 'age')){
    stop('get_slxPlot: argument type should be either age or length')
  }
  
  laa <- get_lengthAtAge(type=laa_typ, par=laa_par, 
                  ages=ages, Tanom=TAnom)
  
  slx <- get_slx(type=selC_typ, par=selCpar, laa=laa)
  
  if(type == 'age'){
    
    xlab <- 'Age'
    xval <- ages
    
  }else{
  
    xlab <- 'Length'
    xval <- laa
    
  }
  
  ylab <- 'Selectivity'
    
  plot(slx ~ xval, las=1, pch=4, cex=1.25, lwd=2, ylab=ylab, xlab=xlab)
  
}
