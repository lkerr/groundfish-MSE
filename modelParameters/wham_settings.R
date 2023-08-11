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
wham_settings$haddockGB <- list(model_name = "haddockGB_model")

# pollock
wham_settings$pollock <- list(model_name = "pollock")

# yellowtailflounderGB
wham_settings$yellowtailflounderGB <- list(model_name = "YTflounderGB")

