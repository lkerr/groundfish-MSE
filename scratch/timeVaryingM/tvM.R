


cmip5 <- read.table(file='data/data_raw/NEUS_CMIP5_annual_means.txt',
                    header=TRUE, skip=2)

laa_par <- c(Linf=114.1, K=0.22, t0=0.17, beta1=5)

paulyM <- function(Linf, K, Temp){
  
  log10M <- -0.0066 - 0.279 * log10(Linf) + 
          0.6543 * log10(K) + 0.4634 * log10(Temp)
  
  out <- c(M = 10^log10M)
  
}


cmipM <- sapply(2:ncol(cmip5), function(x)
                     paulyM(Linf = laa_par['Linf'],
                            K = laa_par['K'],
                            Temp = cmip5[,x]))

meanM <- apply(cmipM, 1, mean)
sdM <- apply(cmipM, 1, sd)

rg <- range(meanM, meanM+sdM, meanM-sdM)

plot(meanM ~ cmip5$year, type = 'n', ylim=rg, xaxs='i',
     las = 1, xlab = 'Year', ylab = 'Mean Pauly M',
     main = 'log10M = -0.0066 - 0.279 * log10(Linf) + 
       0.6543 * log10(K) + 0.4634 * log10(Temp)')

polygon(x = c(cmip5$year, rev(cmip5$year)),
        y = c(meanM - sdM, rev(meanM + sdM)),
        col = 'cornflowerblue', border = 'firebrick1')
box()

lines(meanM ~ cmip5$year, col='firebrick1', lwd=3)    


