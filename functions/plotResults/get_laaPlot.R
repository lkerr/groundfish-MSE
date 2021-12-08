#' @title Plot Length-At-Age with Temperature
#' @description Generate a plot showing the progression of length-at-age as it changes with temperature
#' 
#' @param laa_par A vector of length-at-age parameters (@seealso get_lengthAtAge), obtained from "stock" object
#' @param laa_typ A string describing the type of length-at-age model (see get_lengthAtAge), obtained from "stock" object.
#' @param laafun Name of function to use to calculate length-at-age???
#' @template global_Tanom
#' @param ptyrs A vector of years
#' 
#' @return 
#' 
#' @family postprocess
#' 
#' @export

get_laaPlot <- function(laa_par, laa_typ, laafun, ages, Tanom, ptyrs){

  len <- t(sapply(1:length(Tanom), 
                  function(i) laafun(type='vonB', par=laa_par, 
                                     ages=ages, Tanom=Tanom[i])))
  
  yl <- range(len)
  
  colf <- colorRampPalette(c('darkblue', 'firebrick1'))
  col <- colf(length(Tanom))
  
  par(mar=c(4,4,1,1))
  
  plot(0, type='n', ylim=yl, xlim=range(ages), ann=FALSE, las=1)
  matlines(ages, t(len), lwd=0.5, col=col, lty=1)
  
  mtext(side=1:2, line=2.5, cex=1.25,
        c('Age', 'Length'))
  
  legLabIdx <- c(1, round(length(ptyrs)/2), length(ptyrs))
  legLab <- ptyrs[legLabIdx]
  
  legend('bottomright',
         legend = legLab,
         col = col[legLabIdx],
         lty=1,
         lwd=3,
         bty = 'n',
         cex=1.25)
  
}
