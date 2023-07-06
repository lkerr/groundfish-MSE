# Storage object for WHAM assessment results for the groundfish MSE

# fit <- fit_wham()
# results to store in a separate object (lists are good)
SSBhat <- fit$rep$SSB
J1N <- fit$rep$NAA
F <- fit$rep$F[,1] # Assumes there is one fleet
waa
sel <- fit$rep$selAA[[1]][1,] # This pulls the first selectivity block with [[1]] so this should be checked based on your model setup
M <- fit$rep$MAA[1,] # Pulls first year of natural mortality at age 
mat
R

# need this as an input
wham_settings <- list(model_name = "test", selectivity = list(model = c(rep("logistic",5)),
                                                              initial_pars = list(c(2,0.4), c(2,0.4), c(2,0.4), c(2,0.4), c(2,0.4)),
                                                              fix_pars = list(NULL, NULL, c(1,2),NULL,NULL))) # !!! add this to the function arguments


