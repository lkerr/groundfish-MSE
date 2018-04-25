
# Look at the CMIP5 temperature data

cmip5 <- read.table('data/NEUS_CMIP5_annual_means.txt', header=TRUE, skip=2)

tquant <- t(apply(cmip5[-1], 1, quantile, 
                  probs=c(0.025, 0.05, 0.25, 0.5, 0.75, 0.95, 0.975)))


par(mar=c(4,4,1,1))

plot(NA, type='n', xlim=range(cmip5$year), ylim=range(cmip5[,-1]),
     ylab='Temp', xlab='Year', las=1)

rect(xleft=2018, ybottom=0, xright=2500, ytop=100,
     col='lemonchiffon', border='white')

matplot(cmip5$year, cmip5[-1], type='l',
        col='gray70', add=TRUE)

matplot(cmip5$year, tquant[,c(3:5)], 
        col='gray25', add=TRUE, 
        lwd=c(2,4,2), type='l', lty=1)

abline(v=2018, col='royalblue4', lty=3)
box()
