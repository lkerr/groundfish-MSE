get_assess_results <- function(stock)
{
  assess_results <- data.frame(matrix(nrow=length(stock),ncol=8))
  names(assess_results) <- c("isp","data","results","pars","bmsy","msy","fmsy","q")
  assess_results <- tibble(assess_results)
  for(i in 1:length(stock))
  {
    # NOT SURE WHAT PLAN B SMOOTH PRODUCES FOR EXPECTED CATCH, FOR NOW JUST USING OBSERVED CATCH
    
    # Species
    assess_results$isp[i] <- as.double(i)
    
    # Make "data" object based on if its from a planB smooth or ASAP run
    if(stock[[i]]$stockName %in% c('Goosefish','Silver_hake', 'Spiny_dogfish', "Winter_skate")){
      data.df <- data.frame(t=c(1:length(stock[[i]]$planBest$pred_fit$fit)),biomass=c(stock[[i]]$planBest$pred_fit$fit),catch=c(stock[[i]]$sumCW[1:length(stock[[i]]$planBest$pred_fit$fit)]))
    }
    if(stock[[i]]$stockName %in% c('Atlantic_cod','Atlantic_herring', 'Atlantic_mackerel', "Haddock", 'Winter_flounder', 'Yellowtail_flounder')){
      data.df <- data.frame(t=c(1:length(stock[[i]]$res$SSB)),biomass=c(stock[[i]]$res$SSB),catch=c(stock[[i]]$res$catch.pred))
    }
    
    data.df <- as_tibble(data.df)
    assess_results$data[i] <- list(data.df)
    
    # Make "results" object based on if its from a planB smooth or ASAP run
    if(stock[[i]]$stockName %in% c('Goosefish','Silver_hake', 'Spiny_dogfish', "Winter_skate")){
      results <- list("biomass"=c(stock[[i]]$planBest$pred_fit$fit),"catch"=c(stock[[i]]$sumCW[1:length(stock[[i]]$planBest$pred_fit$fit)]),"pars"=c(NA,NA),"q"=c(1))
    }
    if(stock[[i]]$stockName %in% c('Atlantic_cod','Atlantic_herring', 'Atlantic_mackerel', "Haddock", 'Winter_flounder', 'Yellowtail_flounder')){
      results <- list("biomass"=c(stock[[i]]$res$SSB),"catch"=c(stock[[i]]$res$catch.pred),"pars"=c(NA,NA),"q"=c(1))
    }
    
    assess_results$results[i] <- list(results)
    
    pars <- list(c(NA,NA))
    assess_results$pars[i] <- pars
    
    # Temporarily put in bmsy, msy, fmsy for each species
    assess_results$bmsy[i] <- 100000
    assess_results$msy[i] <- 1000
    assess_results$fmsy[i] <- 0.2
    
    assess_results$q[i] <- 1
    
  }
  
  return(assess_results)
}