

# read in the data
load('data/data_processed/trawlBiol.Rdata') # biol
load(file='data/data_raw/mqt_oisst.Rdata') #mqt_oisst
mqt_oisst <- mqt_oisst[complete.cases(mqt_oisst),]

tdc <- subset(biol, COMNAME == 'ATLANTIC COD')
yss <- substr(tdc$CRUISE, start=1, stop=4)
tdc$YEAR <- as.numeric(yss)
## Run model on early / late time series

# d1 <- subset(tdc, YEAR < 1990)
# d2 <- subset(tdc, YEAR > 2000)
# 
# m1 <- nls(formula = LENGTH ~ exp(log_Linf) *
#             (1 - exp(-exp(log_K) * AGE-t0)),
#           data=d1, start=list(log_Linf=log(150),
#                               log_K=log(0.2), t0=0))
# 
# m2 <- nls(formula = LENGTH ~ exp(log_Linf) * 
#             (1 - exp(-exp(log_K) * AGE-t0)), 
#           data=d2, start=list(log_Linf=log(150), 
#                               log_K=log(0.2), t0=0))
# 
# newage <- 1:20
# p1 <- predict(m1, newdata=list(AGE=newage))
# p2 <- predict(m2, newdata=list(AGE=newage))
# 
# plot(NA, xlim=range(newage), ylim=range(p1,p2))
# lines(p1 ~ newage, col='cornflowerblue', lwd=3)
# lines(p2 ~ newage, col='firebrick1', lwd=3)
# 
# 
# ## Try to integrate temperature as a parameter in a cheap way
# 
names(mqt_oisst)[1] <- 'YEAR'
dat <- merge(tdc, mqt_oisst)
# 
# 
# m1 <- nls(formula = LENGTH ~ exp(log_Linf) * exp(log_gamma) * T *
#                     (1 - exp(-exp(log_K) * AGE-t0)),
#           data=dat,
#           start=list(log_Linf=log(150), log_gamma=log(1),
#                      log_K=log(0.2), t0=0))
# 
# 


# Try in TMB

require(TMB)

# compile the c++ file and make available to R
compile("scratch/growth/2018-08-03/simplegrowth.cpp")
dyn.load(dynlib("scratch/growth/2018-08-03/simplegrowth"))

dat <- dat[complete.cases(dat),]
dat <- subset(dat, AGE < 11 & AGE > 0)

data <- list(n = nrow(dat),
             T = dat$q3 - mean(dat$q3),
             A = dat$AGE,
             L = dat$LENGTH)

# could put the betas on a log scale and force them
# to start positive and head negative. Not doing this lets
# the data decide what to do.
parameters <- list(log_Linf = 4.895, 
                   log_K = -1.984,
                   t0 = 0.101,
                   log_sig = -1,
                   log_gamma = 0.1)

# Set parameter bounds
lb <- list(log_Linf = log(80), 
           log_K = 0.05,
           t0 = -2,
           log_sig = log(0.00001),
           log_gamma = -5)

ub <- list(log_Linf = log(200), 
           log_K = log(0.3),
           t0 = 2,
           log_sig = -0.5,
           log_gamma = 1.5)


map_par <- list(
  # log_Linf = factor(NA),
  # log_K = factor(NA),
  # t0 = factor(NA),
  # log_sig = factor(NA),
  # log_gamma = factor(NA)
)


# map_par <- list() # all parameters active


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

