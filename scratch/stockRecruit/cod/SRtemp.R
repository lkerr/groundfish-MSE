


bbh_base <- read.csv('data/1905-2017sst-3-5-18.csv', stringsAsFactors = FALSE)
sr <- read.csv('data/SAW55SR.csv')

mdy <- as.data.frame(do.call(rbind, strsplit(bbh_base$COLLECTION_DATE, split='\\/')))
qtab <- cbind(1:12, rep(1:4, each=3))
names(mdy) <- c('MONTH', 'DAY', 'YEAR')
mdy$Q <- qtab[match(as.numeric(as.character(mdy$MONTH)), qtab[,1]),2]


bbh <- cbind(mdy, bbh_base)


# get Q1 - Q4 median temp
bbhyv <- data.frame(tapply(bbh$Sea.Surface.Temp.Ave.C, 
                           INDEX=list(mdy$YEAR, mdy$Q), 
                           FUN=median, na.rm=TRUE))
bbhyv$Year <- row.names(bbhyv)
names(bbhyv) <- c('Q1', 'Q2', 'Q3', 'Q4', 'Year')


srt <- merge(sr, bbhyv)
names(srt)[names(srt) == 'SSBMT'] <- 'S'
names(srt)[names(srt) == 'A1Recruitmentx1000'] <- 'R'

idxSSB <- 1:(nrow(srt)-1)
idxR <- 2:nrow(srt)




# load the TMB package
require(TMB)

# compile the c++ file and make available to R
compile('scratch/stockRecruit/SRtemp_rw.cpp')
dyn.load(dynlib("scratch/stockRecruit/SRtemp_rw"))


data <- list(S = srt$S[idxSSB],
             R = srt$R[idxR],
             T = srt$Q3[idxSSB],
             nobs = length(idxSSB))


parameters <- list(log_a = log(0.76),
                   b = -0.00004,
                   c = -0.54,
                   log_sigR = log(1),
                   log_rwebase = 0)

0.76 * srt$S[1]*exp( (-0.00004) * srt$S[1] + (-0.54) * srt$Q3[1])
# Set parameter bounds
lb <- c(log_a = -10,
        b = -10,
        c = -10,
        log_sigR = -10,
        log_rwebase = -10)

ub <- c(log_a = 10,
        b = 10,
        c = 10,
        log_sigR = log(10),
        log_rwebase = log(10))


obj <- MakeADFun(data = data,
                 parameters = parameters,
                 DLL = "SRtemp_rw")


# run the model using the R function nlminb()
opt <- nlminb(start=obj$par, 
              objective=obj$fn, 
              gradient=obj$gr, 
              lower=lb, 
              upper=ub)


sdrep <- sdreport(obj)
rep <- obj$report()



# make a plot

rS <- range(rep$R, rep$Rhat)
newS <- seq(0, rS[2]*4, length.out=250)
newT <- c(12, 15, 18)
newR <- sapply(1:length(newT), function(x){
  rep$a * newS * exp(rep$b * newS + rep$c*newT[x])
})


sclR <- 1000
sclS <- 1000

par(mar=c(4,4,2,1))
plot(0, type='n', xlim=range(newS/sclS), ylim=c(0, max(newR)/sclR),
     xlab='', ylab='', las=1)
matplot(x=newS/sclS, y=newR/sclR, type='l', lwd=3, add=TRUE)

points(rep$S/sclS, rep$R/sclR, pch=3)

mtext(side=1:2, line=c(2.5,2.5), cex=1.25,
      c('SSB (MTx1000)', 'R (millions)'))
legend('top', xpd=NA, col=1:3, lty=1:3, bty='n', ncol=3, lwd=2,
       legend=paste('T=', newT),
       yjust=0, inset=-0.2)


# residual plot
plot(rep$R - rep$Rhat, pch=3, type='b')
abline(h=0, lty=3)




