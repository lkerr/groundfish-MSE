



# make a plot

rS <- range(rep$R, rep$Rhat)
# newS <- seq(0, rS[2]*2, length.out=250)
newS <- seq(0, 100000, length.out=250)
newT <- with(data, round(c(mean(T), mean(T)+1, mean(T)+2)))


pars <- list(a = c(exp(17.2494517), exp(17.19630224)),
             b = c(exp(11.1434321), exp(11.04624509)),
             c = c(-0.3181930, -0.34956934),
             theta = c(NA, 0.05728182),
             log_Rhat0 = c(NA, 11.22524339),
             log_sigR = c(0.4239175, 0.16049534))

newR0 <- sapply(1:length(newT), function(x){
  pars$a[1] * newS / (pars$b[1] + newS) * exp(pars$c[1]*newT[x])})
newR1 <- sapply(1:length(newT), function(x){
  pars$a[2] * newS / (pars$b[2] + newS) * exp(pars$c[2]*newT[x])})



sclR <- 1000
sclS <- 1000

par(mar=c(4,4,2,1))
plot(0, type='n', xlim=range(newS/sclS), 
     ylim=c(0, max(newR0/sclR, newR1/sclR)),
     xlab='', ylab='', las=1)
matplot(x=newS/sclS, y=newR0/sclR, type='l', lwd=3, add=TRUE,
        lty = 1)
matplot(x=newS/sclS, y=newR1/sclR, type='l', lwd=3, add=TRUE,
        lty = 3)

points(rep$S/sclS, rep$R/sclR, pch=3)

mtext(side=1:2, line=c(2.5,2.5), cex=1.25,
      c('SSB (MTx1000)', 'R (millions)'))

legend('topleft', col=c(1,2,3,1,1), lty=c(1,1,1,1,3), bty='n', 
       ncol=2, lwd=2,
       legend = c(paste('T=', newT), 'base', 'AR1'),
       yjust=0)








