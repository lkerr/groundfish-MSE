#' @title Define WHAM model settings
#' 
#' @description The following script loads any specific wham settings for each stock. List names must match available stocks (check modelParameters/stockParameters for most up to date list), but stock order does not matter.
#' The following would run a wham model for stockName with all wham default settings used:
#' wham_settings$stockName = list(model_name = "modelName") 

# Set up storage object for list
wham_settings <- NULL

# GB cod example
wham_settings$codGB <- list(model_name = "codGB", selectivity = list(model = c(rep("logistic",2)),
                                                                     initial_pars = list(c(2,0.4), c(2,0.4)),
                                                                     fix_pars = list(NULL, c(1,2)))) # !!! add this to the function arguments

# GOM cod example using all default WHAM settings
wham_settings$codGOM <- list(model_name = "codGOM")

# haddockGB

# # Setting for the SDM-q linked model
# wham_settings$haddockGB <- list(model_name = "haddockGB_model",
#                                 ecov = list(label = "COG",
#                                             proces_model = "rw",
#                                             mean = matrix(SDManom$metricMean, ncol = 1),
#                                             logsigma = log(SDManom$SE),
#                                             year = matrix(SDManom$Year, ncol = 1),
#                                             lag = 0,
#                                             use_obs = matrix(1, ncol = 1, nrow = nrow(SDManom)),
#                                             where = "q",
#                                             indices = 1,
#                                             how = 1)) # Environmental covariate on spring survey catchability
# Model with no effect
wham_settings$haddockGB <- list(model_name = "haddockGB_model",
                                ecov = list(label = "COG",
                                            proces_model = "none",
                                            mean = matrix(SDManom$metricMean, ncol = 1),
                                            logsigma = log(SDManom$SE),
                                            year = matrix(SDManom$Year, ncol = 1),
                                            lag = 0,
                                            use_obs = matrix(1, ncol = 1, nrow = nrow(SDManom)),
                                            where = "none",
                                            indices = 1,
                                            how = 0)) 


# pollock
wham_settings$pollock <- list(model_name = "pollock")

# yellowtailflounderGB
wham_settings$yellowtailflounderGB <- list(model_name = "YTflounderGB")

