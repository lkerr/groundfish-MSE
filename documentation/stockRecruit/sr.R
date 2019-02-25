

get_SRDat <- function(recDat, stock){
  
  # Subset the data to extract the stock of interest
  tmp <- subset(recDat, STOCK == stock)
  
  # Create new data frame appropriately offset such that the SSB is matched
  # with the correct number of recruits
  nr <- nrow(tmp)
  tmpOff <- tmp
  tmpOff$REC000S <- c(tmp$REC000S[2:nr], NA)
  
  return(tmpOff)
}


srdat <- get_SRDat(recDat = rec, stock = 'GBCOD')





## BH MODEL

# read in the data
load(file='data/data_raw/mqt_oisst.Rdata') #mqt_oisst
saw55 <- read.table('data/data_raw/SAW55SR_codGB.csv', header=TRUE, sep=',')

srt <- merge(saw55, mqt_oisst)


# create a new simpler data file with the data you want
srdat <- as.data.frame(cbind(YEAR = srt$Year,
                             T = srt$q1,
                             S = srt$SSBMT,
                             R = srt$A1Recruitmentx1000 * 1000))
srdat <- srdat[complete.cases(srdat),]


# indexes to use for ssb and R data -- there is a one-year
# lag in this case.
idxSSB <- 1:(nrow(srdat)-1)
idxR <- 2:nrow(srdat)

# load the TMB package
require(TMB)

# compile the c++ file and make available to R
compile('scratch/stockRecruit/cod/BH_7-2018/sr.cpp')
dyn.load(dynlib("scratch/stockRecruit/cod/BH_7-2018/sr"))


data <- list(S = srdat$S[idxSSB],
             R = srdat$R[idxR],
             T = srdat$T[idxSSB] - mean(srdat$T[idxSSB]),
             nobs = length(idxSSB))


parameters <- list(log_a = -1.021315,
                   log_b = 1,
                   c = 0,#-1.319571e-02,
                   log_sigR = log(1))

# Set parameter bounds
lb <- c(log_a = -10,
        log_b = -10,
        c = -10,
        log_sigR = -10)

ub <- c(log_a = 20,#3,
        log_b = 20,#10,
        c = 10,
        log_sigR = log(10))


map_par <- list(
  # log_a = factor(NA),
  # log_b = factor(NA),
  # c = factor(NA)
  # log_sigR = factor(NA)
)


obj <- MakeADFun(data = data,
                 parameters = parameters,
                 DLL = "sr",
                 map = map_par)

active_idx <- !names(lb) %in% names(map_par)

# run the model using the R function nlminb()
opt <- nlminb(start = obj$par, 
              objective = obj$fn, 
              gradient = obj$gr, 
              lower = lb[active_idx], 
              upper = ub[active_idx])


sdrep <- sdreport(obj)
rep <- obj$report()
sdrep$cov


## save useful parameters
srpar <- list(type = 'BHTS',
              names = names(sdrep$value),
              par = sdrep$value,
              se = sdrep$sd,
              cov = sdrep$cov,
              lower = c(0, 0, -Inf, -1, 0),
              upper = c(Inf, Inf, Inf, 1, Inf),
              meanT = mean(srdat$T[idxSSB]))

save(srpar, file='data/data_processed/SR/cod/BHTS.Rdata')


aic <- -2 * rep$NLL + sum(active_idx)


# make a plot

rS <- range(rep$R, rep$Rhat)
# newS <- seq(0, rS[2]*2, length.out=250)
newS <- seq(0, 100000, length.out=250)
newT <- with(data, round(c(mean(T), mean(T)+1, mean(T)+2)))
newR <- sapply(1:length(newT), function(x){
  rep$a * newS / (rep$b + newS) * exp(rep$c*newT[x])})



sclR <- 1000
sclS <- 1000

par(mar=c(4,5,2,1))
plot(0, type='n', xlim=range(newS/sclS), ylim=c(0, max(newR)/sclR),
     xlab='', ylab='', las=1)
matplot(x=newS/sclS, y=newR/sclR, type='l', lwd=3, add=TRUE)

points(rep$S/sclS, rep$R/sclR, pch=3)

mtext(side=1:2, line=c(2.5,3.5), cex=1.25,
      c('SSB (MTx1000)', 'R (millions)'))
legend('top', xpd=NA, col=1:3, lty=1:3, bty='n', ncol=3, lwd=2,
       legend=paste('T = +', newT),
       yjust=0, inset=-0.15)


# residual plot
plot(rep$R - rep$Rhat, pch=3, type='b')
abline(h=0, lty=3)




# ## Simple model to get starting values
# srt <- list(log_a = 17,
#             log_b = 10.5,
#             c = -0.54)
# 
# m <- nls(R ~ exp(log_a)*S / (exp(log_b) + S) *exp(c*T),
#          data=data,
#          start = srt)
# coef(m)
# 
# plot(data$R ~ data$S, xlim=c(0, 250000), ylim=c(0, 1e8))
# newx <- seq(0, 250000, length.out=100)#range(data$S)
# newy <- exp(coef(m)[1]) * newx / (exp(coef(m)[2]) + newx) * 
#         exp(coef(m)[3] * mean(data$T))
# lines(newy ~ newx, lty=1, col='blue')
# 
# 
# 
# 
# 
# 
# ## Simple model to get starting values
# srt <- list(log_a = 17,
#             log_b = 10.5)
# 
# m <- nls(R ~ exp(log_a) * S / (exp(log_b) + S),
#          data=data,
#          start = srt)
# par <- coef(m)
# 
# xd <- 300000#max(data$S)
# plot(data$R ~ data$S, xlim=c(0, xd), ylim=range(data$R))
# newx <- seq(0, xd, length.out=100)
# newy <- exp(par[1]) * newx / (exp(par[2]) + newx)
# lines(newy ~ newx, lty=1, col='blue')
# 
