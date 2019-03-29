


plotParEstBds <- function(rep){
  
  x <- 1:length(rep$lb)
  est <- rep$sdrep$par.fixed
  
  nmsEst <- names(est)
  nms <- names(rep$lb)
  
  noEstInd <- is.na(match(nms, nmsEst))

  est <- numeric(length(nms))
  est[noEstInd] <- unlist(rep$start[noEstInd])
  est[!noEstInd] <- rep$sdrep$par.fixed
  names(est) <- nms

  yl <- range(rep$lb, rep$ub)
  xl <- c(0, max(x) + 1)
  
  par(mar = c(4,4,3,2))
  
  plot(NA, xlim = xl, ylim = yl, las = 1, xaxt='n',
       xlab = '', ylab = '')
 
  axis(side = 1,
       at = x,
       labels = nms,
       cex.axis = 1)
  
  mtext(side = 1:2,
        line = c(2.5,2.5),
        cex = 1.25,
        text = c('Parameter', 'Value'))
        
  
  lty <- rep$estPar
  lty[is.na(lty)] <- 3

  arrows(x0 = x,
         y0 = unlist(rep$lb),
         y1 = unlist(rep$ub),
         code = 3,
         angle = 90,
         length = 0.1,
         lty = lty)
  
  points(unlist(rep$start) ~ x, cex=1.75)
  points(est ~ x, col='red' , pch=16)
  
  legend(x = 'top',
         legend = c('start', 'est', 'boundRg'),
         bty = 'n',
         cex = 1.25,
         inset = -.15,
         ncol = 3,
         pch = c(1, 16, NA),
         lty = c(0, 0, 1),
         col = c('black', 'red', 'black'),
         xpd = NA,
         x.intersp = c(0.01, 0.01, 0.4),
         text.width = 0.75)
  
}


