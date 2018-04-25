


# path_current <- Sys.getenv('PATH')
# path_new <- paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;', 
#                    path_current)
# Sys.setenv(PATH=path_new)

# load the TMB package
require(TMB)


# compile the c++ file and make available to R
compile("scratch/growth/tmbModel/growth.cpp")
dyn.load(dynlib("scratch/growth/tmbModel/growth"))


# read in the data
load('data/data_processed/trawlBiol.Rdata') # biol
tdc <- subset(biol, COMNAME == 'ATLANTIC COD')

yss <- substr(tdc$CRUISE, start=1, stop=4)
tdc$YEAR <- as.numeric(yss)
tdcsub0 <- tdc[,c('YEAR', 'AGE', 'LENGTH')]
tdcsub1 <- subset(tdcsub0, AGE > 0)
tdcsub <- tdcsub1[complete.cases(tdcsub1),]


# number of years to include in the analysis will be the
# number of years there are altogether plus an initialization
# period of mxage
mxage <- max(tdcsub$AGE)
mxyear <- max(tdcsub$YEAR)
nyear <- length(unique(tdcsub$YEAR))
nage <- length(unique(tdcsub$AGE))

data <- list(nyear = nyear,
             nage = nage,
             mxage = mxage,
             mxyear = mxyear,
             nrec = nrow(tdcsub),
             YEAR = tdcsub$YEAR,
             AGE = tdcsub$AGE,
             LENGTH = tdcsub$LENGTH)

parameters <- list(log_Linf = log(150), 
                   log_K = log(0.2),
                   log_oe_L = 0.5)

# Set parameter bounds
lb <- c(log_Linf = log(80),
        log_K = log(0.001),
        log_oe_L = log(0.001))

ub <- c(log_Linf = log(200),
        log_K = log(1),
        log_oe_L = log(2))


map_par <- list(
  # log_Linf = factor(NA),
  # log_K = factor(NA)
  # log_oe_L = factor(NA)
)


# map_par <- list() # all parameters active


# make an objective function
obj <- MakeADFun(data = data,
                 parameters = parameters,
                 DLL = "growth",
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

plot(LENGTH ~ AGE, data=tdcsub, ylim=c(0, 155),
     xlim=c(0, 20))
vb <- function(x) rep$Linf * (1-exp(-rep$K*x))
curve(vb, from=0, to=20, add=TRUE, col='blue', lwd=5)


m <- nls(LENGTH~Linf * (1-exp(-K*(AGE-t0))),
         data=tdcsub,
         start=list(Linf=120, K=0.2, t0=0))
vb2 <- function(x) coef(m)['Linf'] * 
                   (1-exp(-coef(m)['K']*(x-coef(m)['t0'])))
curve(vb2, from=0, to=20, add=TRUE, col='red', lwd=2)


m2 <- nls(LENGTH~Linf * (1-exp(-K*(AGE))),
         data=tdcsub,
         start=list(Linf=120, K=0.2))
vb3 <- function(x) coef(m2)['Linf'] * 
  (1-exp(-coef(m2)['K']*x))
curve(vb3, from=0, to=20, add=TRUE, col='green', lwd=3)
