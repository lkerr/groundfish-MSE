
get_WHAMecov <- function(stock_wham_settings,...){
  
  if(stock_wham_settings$model_name == "codWGOM"){ 
    
        ecov <-list(
      label = "Recruitment",
      logsigma = 'est_1', # estimate obs sigma, 1 value shared across years
      process_model = 'ar1', # "rw" or "ar1"
      recruitment_how = matrix("controlling-lag-1-linear")) # limiting when BH g > 0 I - think
  
        # update the rest of the wham settings for when you use ecovs
        NAA_re = NULL
        
        recruit_model = 3
        
        updates <- list(ecov, NAA_re, recruit_model)
        
      }else{
stop("no ecov setting for stock")
  }
    

    

    return(updates)
    
}


