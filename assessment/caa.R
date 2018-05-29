


# load the TMB package
require(TMB)

# Ensure that TMB will use the Rtools compiler (only windows ... and 
# not necessary on all machines)
if(platform != 'Linux'){
  path_current <- Sys.getenv('PATH')
  path_new <- paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                     path_current)
  Sys.setenv(PATH=path_new)
}

# compile the c++ file and make available to R
TMB::compile("assessment/caa.cpp")
dyn.load(dynlib("assessment/caa"))


data <- tmb_dat

parameters <- tmb_par

# Set parameter bounds
lb <- tmb_lb

ub <- tmb_ub

# whatever is contained in this list (i.e., not commented out) will be an
# inactive parameter so the starting value will be used.
map_par <- list(
  log_M = factor(NA),
  # R_dev = factor(rep(NA, ncaayear-1)),
  # log_ipop_mean = factor(NA),
  # ipop_dev = factor(rep(NA, nage)),
  # log_qC = factor(NA),
  # log_qI = factor(NA),
  # log_selC = factor(rep(NA, length(selC))),
  log_oe_sumCW = factor(NA),
  log_oe_sumIN = factor(NA),
  log_pe_R = factor(NA)
)

# map_par <- list() # all parameters active


# make an objective function
obj <- MakeADFun(data = data,
                 parameters = parameters,
                 DLL = "caa",
                 map = map_par
)


# index for active parameter bounds
# (note that R does not give an error message if the wrong
# number of parameter bounds are given
# if having estimation problems parameter bounds are a good
# place to check)
active_idx <- !names(lb) %in% names(map_par)



# add any noise to the parameter starting values
# (note that the impact of the CV also depends on what the level
# of the bounds is specified at). Only add noise to the active
# parameters -- don't want to distort the values of the inactive
# parameters.
for(i in which(active_idx)){
  tmb_par[[i]] <- get_svNoise(tmb_par[[i]],
                              cv=1,
                              lb=tmb_lb[[i]], ub=tmb_ub[[i]])
}



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

rep_data <- rep[c('obs_sumCW',
                  'obs_paaCN',
                  'obs_sumIN',
                  'obs_paaIN',
                  'obs_effort',
                  'laa',
                  'waa',
                  'slxI',
                  'timeI')]

rep_par <- rep[c('log_M',
                 'R_dev',
                 'log_ipop_mean',
                 'ipop_dev',
                 'oe_sumCW',
                 'oe_sumIN',
                 'log_pe_R',
                 'log_selC',
                 'log_qC',
                 'log_qI')]

rep_NLL <- rep[c('NLL',
                 'NLL_sumCW',
                 'NLL_sumIN',
                 'NLL_R_dev',
                 'NLL_paaCN',
                 'NLL_paaIN')]


d2 <- data.frame(rep$sumCW, rep$sumIN,
                 rep$paaCN, rep$paaIN)


if(FALSE){
  par(oma=c(0,4,0,0), mfcol=c(2,2), mar=c(0, 0, 0, 0))
  
  plot(rep$obs_sumCW, ylim=range(rep$sumCW, rep$obs_sumCW),
       xaxt='n', ann=FALSE, las=1)
  lines(rep$sumCW)
  
  plot(rep$obs_sumIN, ylim=range(rep$sumIN, rep$obs_sumIN), las=1,
       xaxt='n')
  lines(rep$sumIN)
  
  plot(rep$obs_paaCN[5,], ylim=c(0, 1),
       xaxt='n', yaxt='n', ann=FALSE)
  lines(rep$paaCN[5,], ylim=c(0, 1))
  
  plot(rep$obs_paaIN[5,], ylim=c(0, 1),
       xaxt='n', yaxt='n', ann=FALSE)
  lines(rep$paaIN[5,], ylim=c(0, 1))
}




#############################
#############################
#############################

# # Testing the dmultinom function in R
# 
# # set of xs, ps and ns. Default n is the sum of the 
# # x vector
# x <- 1:3
# p <- c(8, 4, 3)
# p <- p / sum(p)
# n <- sum(x)
# 
# # writing out the equation versus using the
# # dmultinom function
# log(factorial(n) / prod(factorial(x)) * prod(p^x))
# dmultinom(x=x, p=p, log=TRUE)
# 
# 
# # how to integrate effective sample size? Looks like it
# # works if you just make x into a vector of probabilities
# # instead and then multiply it by n. Basically you are just
# # scaling the xs by whatever you want the effective sample
# # size to be.
# 
# n2 <- 75
# x2 <- x / sum(x)
# 
# -log(factorial(n2) / prod(factorial(x2*n2)) * prod(p^(x2*n2)))
# -dmultinom(x=x2*n2, p=p, log=TRUE)

