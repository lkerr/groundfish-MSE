


TAnomType <- 'gdy' # 'gdy' or 'point'

tempAgeMax <- 2 # care about temp through this age


path0 <- Sys.getenv('PATH')
path1 <-  paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                 path0)
Sys.setenv(PATH=path1)

# read in the data
load('data/data_processed/trawlBiol.Rdata') # biol
TAnom <- read.csv('data/data_processed/TAnom.csv', header=TRUE)



tdc <- subset(biol, COMNAME == 'ATLANTIC COD')
yss <- substr(tdc$CRUISE, start=1, stop=4)
tdc$YEAR <- as.numeric(yss)

# Merge the temperature anomaly data with the individual trawl survey
# record data
dat <- merge(tdc, TAnom)

# Subset the data to the columns we care about and remove NA records
datSub <- dat[,c('YEAR', 'COMNAME', 'LENGTH', 'AGE', 'TANOM')]
datSub <- subset(datSub, AGE < 11 & AGE > 0)
datSub <- datSub[complete.cases(datSub),]

# birth year
datSub$BYEAR <- datSub$YEAR - datSub$AGE

# Vector that holds the sum of the temperature anomaly
sumAnom <- numeric(nrow(datSub))
for(i in 1:nrow(datSub)){
  
  temp <- datSub[i,]
  iYears <- (temp$YEAR - temp$AGE):temp$YEAR
  iAnom <- TAnom[TAnom$YEAR %in% iYears,2]
  
  # Consider only the temperatures experienced over the first
  # tempAgeMax years
  iAnom <- head(iAnom, tempAgeMax+1) # +1 to account for age-0
  sumAnom[i] <- sum(iAnom)
  
}
datSub$sumAnom <- sumAnom





require(TMB)

# compile the c++ file and make available to R
compile("documentation/growth/growthScratch/growthTemp.cpp")
dyn.load(dynlib("documentation/growth/growthScratch/growthTemp"))

if(TAnomType == 'gdy'){
  runT <- datSub$sumAnom
}else if(TAnomType == 'point'){
  runT <- datSub$TANOM
}else{
  stop('check value for TAnomType')
}

datMod <- list(n = nrow(datSub),
               T = runT,
               A = datSub$AGE,
               L = datSub$LENGTH)

parameters <- list(log_Linf = log(130), 
                   log_K = log(0.2),
                   t0 = 0,
                   log_sig = log(0.2),
                   beta1 = 0,
                   beta2 = 0)

# Set parameter bounds
lb <- list(log_Linf = log(30), 
           log_K = log(0.00001),
           t0 = -5,
           log_sig = log(0.00001),
           beta1 = -30,
           beta2 = -10)

ub <- list(log_Linf = log(200), 
           log_K = log(1),
           t0 = 5,
           log_sig = log(10),
           beta1 = 10,
           beta2 = 10)


map_par <- list(
  # log_Linf = factor(NA),
  # log_K = factor(NA),
  # t0 = factor(NA),
  # log_sig = factor(NA),
  # beta1 = factor(NA)
  beta2 = factor(NA)
)



# make an objective function
obj <- MakeADFun(data = datMod,
                 parameters = parameters,
                 DLL = "growthTemp",
                 map = map_par
)


# index for active parameter bounds
# (note that R does not give an error message if the wrong
# number of parameter bounds are given
# if having estimation problems parameter bounds are a good
# place to check)
active_idx <- !names(lb) %in% names(map_par)



# run the model using the R function nlminb()
opt <- nlminb(start = obj$par,
              objective = obj$fn,
              gradient = obj$gr,
              lower = unlist(lb[active_idx]),
              upper = unlist(ub[active_idx]))



# estimates and standard errors (run after model optimization)
sdrep <- sdreport(obj)


# list of variables exported using REPORT() function in c++ code
rep <- obj$report()

AICk <- length(sdrep$par.fixed)
AIC <- 2 * AICk - 2 * log(-rep$NLL)

relE <- mean((rep$L - rep$Lhat) / rep$Lhat)
slp <- coef(lm(rep$Lhat ~ rep$L))[2]



##############
##############
##############
##############

gplot <- function(Linf, K, t0, dat){
  
  plot(dat$L ~ dat$A, col='gray', pch=16, cex=0.5)
  
  newx <- seq(0, max(datMod$A), length.out = 100)
  pred <- sapply(1:length(Linf),
                 function(x){
                   Linf[x] * (1-exp(-K[x]*(newx-t0[x])))
                 })
  
  matlines(newx, pred, col=1:length(Linf), lty=1, lwd=c(5,3))
  
}

# Compare GDY M2 with point M3 -- assuming avg temperature
gplot(Linf = c(exp(4.81), exp(4.77)),
      K = c(exp(-1.73), exp(-1.70)),
      t0 = c(-0.43, -0.52),
      dat = datMod)




# Assuming "best" point model (M3 ... affects K) what is the 
# behavior over different temperature anomalies

gplotT <- function(par, f, TAnom){
  
  age <- 0:15
  pred <- sapply(1:length(TAnom),
                 function(x){
                   f(par, age, TAnom[x])
                 })
  
  matplot(age, pred, col=1:length(TAnom), lwd=3, type='l', lty=1)
  legend('topleft',
         legend = TAnom,
         lty = 1,
         lwd = 3,
         col = 1:length(TAnom),
         title = 'Anomaly',
         bty = 'n',
         cex = 0.75)
  
}


f1 <- function(par, age, TAnom){
  pL <- (par$Linf + par$beta1 * TAnom ) * (1 - exp(-par$K * (age - par$t0)))
  return(pL)
}

f2 <- function(par, age, TAnom){
  pL <- par$Linf * (1 - exp(-(par$K + par$beta2 * TAnom) * (age - par$t0)))
  return(pL)
}

ta <- (-2):2

# Predicted values for point Model 3 (affects K) over different anomalies
gplotT(par = list(Linf = exp(4.79),
                  K = exp(-1.70),
                  t0 = -0.52,
                  beta2 = -0.026),
       f = f2,
       TAnom = ta)


# Predicted values for gdy Model 2 (affects Linf) over different anomalies
gplotT(par = list(Linf = exp(4.81),
                  K = exp(-1.73),
                  t0 = -0.43,
                  beta1 = -3.48),
       f = f1,
       TAnom = ta)

