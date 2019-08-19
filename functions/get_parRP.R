




get_parRP <- function(fun, type, env){
  
  
  if(fun == 'get_FBRP'){
  
	if(type == 'YPR'){
	
	  par <- list(type = 'YPR',
	              FRPpar = fbrpLevel,
				  sel = slxC,
				  waa = waa,
				  M = mean(M))
	  
	}else if(type == 'SPR'){
	
	  par <- list()
	  
	}else if(type == 'Mbased'){
	
	  par <- list()
	  
	}else{
	
	  stop('get_parRP: type argument not recognized')
	  
	}
  
  
  
  }else if(fun == 'get_BBRP'){
  
  
  
  }else if(fun == 'get_nextF'){
  
  
  
  }else{
  
	stop('get_parRP: function arg not recognized')
	
  }
  
  
  
  
}



