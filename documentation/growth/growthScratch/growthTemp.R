


TAnomType <- 'gdy' # 'gdy' or 'point'

tempAgeMax <- 5 # care about temp through this age


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
dyn.load(dynlib("documentation/growth/growthScratch/simplegrowth"))

if(TAnomType == 'gdy'){
  runT <- datSub$sumAnom
}else if(TAnomType == 'point'){
  runT <- datSub$TANOM
}else{
  stop('check value for TAnomType')
}

datMod <- list(n = nrow(datSub),
               T = datSub$sumAnom,
               A = datSub$AGE,
               L = datSub$LENGTH)

parameters <- list(log_Linf = 4.895, 
                   log_K = -1.984,
                   t0 = 0.101,
                   log_sig = -1,
                   log_beta1 = 1,
                   log_beta2 = 1)

# Set parameter bounds
lb <- list(log_Linf = log(80), 
           log_K = 0.05,
           t0 = -2,
           log_sig = log(0.00001),
           log_beta1 = -5,
           log_beta2 = 5)

ub <- list(log_Linf = log(200), 
           log_K = log(0.3),
           t0 = 2,
           log_sig = -0.5,
           log_beta1 = 1.5,
           log_beta2 = 5)


map_par <- list(
  # log_Linf = factor(NA),
  # log_K = factor(NA),
  # t0 = factor(NA),
  # log_sig = factor(NA),
  # log_beta1 = factor(NA),
  # log_beta2 = factor(NA)
)



# make an objective function
obj <- MakeADFun(data = data,
                 parameters = parameters,
                 DLL = "simplegrowth",
                 map = map_par
)


# index for active parameter bounds
# (note that R does not give an error message if the wrong
# number of parameter bounds are given
# if having estimation problems parameter bounds are a good
# place to check)
active_idx <- !names(lb) %in% names(map_par)



# run the model using the R function nlminb()
opt <- nlminb(start=obj$par,
              objective=obj$fn,
              gradient=obj$gr,
              lower=unlist(lb[active_idx]),
              upper=unlist(ub[active_idx]))



# estimates and standard errors (run after model optimization)
sdrep <- sdreport(obj)


# list of variables exported using REPORT() function in c++ code
rep <- obj$report()





