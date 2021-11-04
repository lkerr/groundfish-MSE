#' @template global_Tanom

# Get plot that shows the progression of length-at-age as it changes with
# temperature





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
