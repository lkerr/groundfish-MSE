#' @title Define WHAM model settings
#' 
#' @description The following script loads any specific wham settings for each stock. List names must match available stocks (check modelParameters/stockParameters for most up to date list), but stock order does not matter.
#' The following would run a wham model for stockName with all wham default settings used:
#' wham_settings$stockName = list(model_name = "modelName") 

# Set up storage object for list
wham_settings <- NULL

# GB cod example
wham_settings$codGB <- list(model_name = "codGB")

# GOM cod example using all default WHAM settings
wham_settings$codGOM <- list(model_name = "codGOM")


if(nfleet ==2){
  
  wham_settings$codWGOM <- list(model_name = "codWGOM",
                                
                                selectivity = list(model=c("age-specific","age-specific", "age-specific"), # selectivity for catch C, catch r, index
                                                   initial_pars=list(stock$codWGOM$selC,
                                                                     stock$codWGOM$selR,
                                                                     stock$codWGOM$selI),
                                                   fix_pars=list(which(stock$codWGOM$selC == 1),
                                                                 which(stock$codWGOM$selR == 1),
                                                                 which(stock$codWGOM$selI == 1)
                                                   )),
                                  recruit_model = 2,
            
                                
                                NAA_re = list(sigma = "rec+1", cor = "2dar1"),
                                
                                basic_info = list(fracyr_SSB = 0, fracyr_indices = 0.5)
                                
  )}else{
  
  wham_settings$codWGOM <- list(model_name = "codWGOM",
                                
                                selectivity = list(model=c("age-specific","age-specific"), # selectivity for catch, index
                                                   initial_pars=list(stock$codWGOM$selC,
                                                                     stock$codWGOM$selI),
                                                   fix_pars=list(which(stock$codWGOM$selC==1),
                                                                 which(stock$codWGOM$selI ==1)
                                                   )),

                                recruit_model = 2,
                                
                                NAA_re = list(sigma = "rec+1", cor = "2dar1"),
                                
                                basic_info = list(fracyr_SSB = 0, fracyr_indices = 0.5)
                                
  )
}


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
wham_settings$haddockGB <- list(model_name = "haddockGB_model")

# pollock
wham_settings$pollock <- list(model_name = "pollock")

# yellowtailflounderGB
wham_settings$yellowtailflounderGB <- list(model_name = "YTflounderGB")
