### MSPROD equation with system cap
## Solves the multsipecies operating model dynamics for a single time step given parameters, a set of harvest rates, and the current biomass
## Given a maximum catch on the system
dNbydt <- function(t,X=c(1,0),parms=list(r=rep(0.4,1),
                                         KGuild=rep(2,1),
                                         Ktot=10,
                                         alpha=matrix(0,nrow=1,ncol=1),
                                         Guildmembership=1,
                                         BetweenGuildComp=matrix(0,nrow=1,ncol=1),
                                         WithinGuildComp=matrix(0,nrow=1,ncol=1),
                                         hrate=0,maxcat=0)) {
  Nsp <- length(X)/2
  N <- X[1:Nsp]
  testcat <- sum(parms$hrate*N,na.rm=TRUE)
  frac <- 1
  if (testcat>parms$maxcat) frac <- parms$maxcat/testcat
  hrate <- parms$hrate*frac
  NG <- aggregate(N,by=list(parms$Guildmembership),sum,na.rm=TRUE)
  NG <- t(parms$BetweenGuildComp)%*%NG$x
  dN <- parms$r*N*(1-(N/parms$KGuild[parms$Guildmembership])-(t(parms$WithinGuildComp)%*%N)/parms$KGuild[parms$Guildmembership]-NG[parms$Guildmembership]/(parms$Ktot-parms$KGuild[parms$Guildmembership]))- parms$alpha%*%N*N-hrate*N
  #dN <- pmax(rep(0.0001,length(N)),r*N*(1-(N/KGuild[Guildmembership])-(t(WithinGuildComp)%*%N)/KGuild[Guildmembership]-NG[Guildmembership]/(Ktot-KGuild[Guildmembership]))- alpha%*%N*N-hrate*N)
  cat <- hrate*N
  predloss <-  parms$alpha%*%N*N
  betweenloss <- parms$r*N*NG[parms$Guildmembership]/(parms$Ktot-parms$KGuild[parms$Guildmembership])
  withinloss <- parms$r*N*(parms$WithinGuildComp%*%N)/parms$KGuild[parms$Guildmembership]
  results <- list(deriv=c(dN,cat),predloss=predloss,withinloss=withinloss,betweenloss=betweenloss)
  return(results)
}

get_om_pars <- function() {
  pars = NULL
  pars$Nsp <- 4
  pars$Nyr <- 50
  pars$Fuse <- c(0.01	,
                 0.04	,
                 0.07	,
                 0.1	,
                 0.13	,
                 0.16	,
                 0.19	,
                 0.22	,
                 0.25	,
                 0.28	,
                 0.31	,
                 0.34	,
                 0.37	,
                 0.4	,
                 0.43	,
                 0.46	,
                 0.49	,
                 0.52	,
                 0.55	,
                 0.58	,
                 0.61	,
                 0.64	,
                 0.67	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.7	,
                 0.65	,
                 0.6	,
                 0.55	,
                 0.5	,
                 0.45	,
                 0.4	,
                 0.35	,
                 0.3	,
                 0.25,
                 0.2)
  pars$r <- c(0.7, 0.4, 0.25, 0.5)
  pars$K <- rep(1000, pars$Nsp)
  pars$q <- c(0.8,0.5,0.2,0.65)
  pars$InitBio <- rep(1000, pars$Nsp)
  pars$complex <- c(1,2,2,1)
  return(pars)
}

get_om <- function(pars) {
  iyr = 1
  Nsp <- length(pars$r)
  parms = list(
    r = pars$r,
    KGuild = pars$K,
    Ktot = sum(pars$K, na.rm = TRUE),
    alpha = matrix(0, nrow = pars$Nsp, ncol = pars$Nsp),
    Guildmembership = 1:pars$Nsp,
    BetweenGuildComp = matrix(0, nrow =
                                pars$Nsp, ncol = pars$Nsp),
    WithinGuildComp = matrix(0, nrow =
                               pars$Nsp, ncol = pars$Nsp),
    q = pars$q,
    hrate = pars$q * 0,
    maxcat = 1e+06
  )
  init_vec <- c(pars$InitBio,rep(0,length(pars$InitBio)))
  names(init_vec) <- c(paste0("biomass_",1:pars$Nsp),paste0("catch_",1:pars$Nsp))
  XX <- purrr::accumulate(pars$Fuse, om_update, .init = init_vec, parms = parms)
  return(XX)
}

om_update <- function(X, Fstar, parms) {
  iyr <- 1
  Nsp <- length(parms$r)
  parms$hrate <- Fstar*parms$q
  #X <- c(N[1:Nsp],rep(0,Nsp))
  x <- deSolve::ode(X,seq(iyr-1,(iyr),1),dNbydt,parms=parms,method="rk4")
  om_vec <- x[2,2:(1+2*Nsp)]
  om_vec[(1+Nsp):(2*Nsp)] <- om_vec[(1+Nsp):(2*Nsp)] - x[1,(2+Nsp):(1+2*Nsp)]
  names(om_vec) <- c(paste0("biomass_",1:Nsp),paste0("catch_",1:Nsp))
  return(om_vec)
}


run_om <- function(input) {
  
  #pars <- get_om_pars()
  om <- get_om(input)
  names(om) <- 1:length(om)
  #om_results <- bind_cols(om)
  #names(om_results) <- c(paste0("biomass_",1:pars$Nsp),paste0("catch_",1:pars$Nsp))
  om_long <- do.call(bind_rows, om) %>%
    rowid_to_column() %>%
    pivot_longer(values_to = "value", names_to = "variable", -rowid) %>%
    separate(col = "variable", into = c("type", "isp")) %>%
    rename("t" = rowid) %>%
    mutate(complex = ifelse(isp %in% c(1,4), 1, 2))
  return(om_long)
}

gen_data <- function(om_long) {
  #set.seed(365)
  sigma_b <- 0.001 #0.35
  sigma_c <- 0.001 #0.05
  em_data <- om_long %>%
    mutate(data_sd = ifelse(type == "biomass",sigma_b,sigma_c),
           err = rnorm(nrow(om_long),0,data_sd),
           data = value*exp(err-0.5*data_sd*data_sd)) %>%
    mutate(t = ifelse(type=="catch",t-1,t)) %>%
    dplyr::filter(t != 0) %>%
    mutate(isp = as.numeric(isp)) %>%
    I()
  #em_data
  ss_data <- em_data %>%
    select(t, isp, type, data) %>%
    ungroup() %>%
    I()
  Nsp <- max(ss_data$isp)
  complex_data <- em_data %>%
    select(t, isp, type, data, complex) %>%
    group_by(t, complex, type) %>%
    summarize(data = sum(data)) %>%
    ungroup() %>%
    mutate(isp = complex+Nsp) %>%
    select(-complex) %>%
    I()
  Nsp <- max(complex_data$isp)
  system_data <- em_data %>%
    group_by(t, type) %>%
    summarize(data = sum(data)) %>%
    ungroup() %>%
    mutate(isp = rep(Nsp+1,nrow(.))) %>%
    I()
  gendata <- bind_rows(ss_data, complex_data, system_data)
  #  gendata <- list(ss_data = ss_data,
  #                  complex_data = complex_data,
  #                 system_data = system_data)
  return(gendata)
}

do_pseudo_assess <- function(data, isp, Nsp = 4) {
  #runs a logistic production model given a data frame with variable names
  # biomass -> time series of survey index
  # catch -> time series of catches
  cpa2 <- readRDS("functions/hydra/cpa2.rds")
  ini.parms <- log(c(5000, 0.6)) #log(1200), log(0.1), 0.3)
  # Fit the logistic model to data:  
  biomass <- as.vector(data$biomass)
  catch <- as.vector(data$catch)
  #single species, no assessment
  #  if (isp <= Nsp) {
  results <- NULL
  results$biomass <- biomass
  # if (isp == 11) results$biomass <- cpa2$bio[cpa2$complex==1]
  # if (isp == 12) results$biomass <- cpa2$bio[cpa2$complex==2]
  # if (isp == 13) results$biomass <- cpa2$bio[cpa2$complex==3]
  results$catch <- catch
  results$pars <- c(NA,NA)
  results$q <- 1
  # }
  #  if (isp > Nsp) {
  #  results <- assess(catch,biomass,calc.vcov=FALSE,ini.parms)
  #  }
  # results <- optim(c(0.6, -0.001), get_preds, 
  #       biomass = as_vector(data$biomass),
  #       catch = as_vector(data$catch),
  #       method = "BFGS")
  return(results)
}

do_assess <- function(data) {
  #runs a logistic production model given a data frame with variable names
  # biomass -> time series of survey index
  # catch -> time series of catches
  ini.parms <- log(c(5000, 0.6)) #log(1200), log(0.1), 0.3)
  # Fit the logistic model to data:  
  biomass <- as_vector(data$biomass)
  catch <- as_vector(data$catch)
  results <- assess(catch,biomass,calc.vcov=FALSE,ini.parms)
  # results <- optim(c(0.6, -0.001), get_preds, 
  #       biomass = as_vector(data$biomass),
  #       catch = as_vector(data$catch),
  #       method = "BFGS")
  return(results)
}

get_preds <- function(beta, biomass, catch) {
  pred_asp <- beta[1]*biomass + beta[2]*(biomass^2)
  obs_asp <- catch + diff(biomass)
  rss <- sum((obs_asp - pred_asp)^2,na.rm=TRUE)
  return(rss)
}

run_assessments <- function(emdata) {
  #this piece needed for the example, would not use this in the mse loop because the data is generated elsewhere
  emdata <- gen_data(emdata) %>% 
    group_by(isp) %>% 
    pivot_wider(names_from = type,
                values_from = data) %>% 
    arrange(t) %>% 
    nest() %>% 
    I()
  
  
  ## runs a set of assessments and extracts results
  # emdata is a nested tibble with each row being the assessment to be run
  # emdata has variables
  #. isp -> an indicator (doesn't have to be species)
  # data -> a dataframe with variables t (time, not used), biomass (survey index), catch
  results <- emdata %>%
    tibble() %>% 
    mutate(results = map(data, do_assess),  #runs the assessments
           pars = map(results, "pars"),   #extracts parameter estimates
           bmsy = exp(map_dbl(pars, 1))/2,  #extracts estimated reference points
           msy = exp(map_dbl(pars, 2))*bmsy/2,
           fmsy = exp(map_dbl(pars, 2))/2,
           q = map_dbl(results, "q") #extracts estiamted catchability
    ) %>% 
    I()
}

run_pseudo_assessments <- function(emdata) {
  #this piece needed for the example, would not use this in the mse loop because the data is generated elsewhere
    emdata <- gen_data(emdata) %>% 
    #emdata <- emdata %>%
      ungroup()%>%
    group_by(isp) %>% 
    pivot_wider(names_from = type,
                values_from = data) %>%
    arrange(t) %>%
    nest() %>%
    I()
    # 
  ## runs a set of assessments and extracts results
  # emdata is a nested tibble with each row being the assessment to be run
  # emdata has variables
  #. isp -> an indicator (doesn't have to be species)
  # data -> a dataframe with variables t (time, not used), biomass (survey index), catch
  results <- emdata %>%
    tibble() %>% 
    mutate(results = map2(data, isp, do_pseudo_assess, Nsp = nrow(emdata)-3),  #runs the assessments
           pars = map(results, "pars"),   #extracts parameter estimates
           bmsy = exp(map_dbl(pars, 1))/2,  #extracts estimated reference points
           msy = exp(map_dbl(pars, 2))*bmsy/2,
           fmsy = exp(map_dbl(pars, 2))/2,
           q = map_dbl(results, "q") #extracts estiamted catchability
    ) %>% 
    I()
  results$bmsy[11:14] <- c(147586, 39557, 44059, 277117)
  results$msy[11:14] <- c(62401, 20350, 20286, 73446)
  results$fmsy[11:14] <- c(0.211, 0.257, 0.230, 0.265)
  return(results)
}


schaefer <- function(B,C,K,r) {
  #function schaefer takes the current biomass, a catch, 
  #and the model parameters to compute next year's biomass
  res <- B + B * r * (1 - B/K) - C
  return(max(0.001,res))  # we add a constraint to prevent negative biomass
}

# Now a function to do the biomass projection:  
dynamics <- function(pars,C,yrs) {
  # dynamics takes the model parameters, the time series of catch, 
  # & the yrs to do the projection over
  
  # first extract the parameters from the pars vector (we estimate K in log-space)
  K <- exp(pars[1])
  r <- exp(pars[2])
  
  # find the total number of years
  nyr <- length(C) + 1
  
  # if the vector of years was not supplied we create 
  # a default to stop the program crashing
  if (missing(yrs)) yrs <- 1:nyr
  
  #set up the biomass vector
  B <- numeric(nyr)
  
  #intialize biomass at carrying capacity
  B[1] <- K
  # project the model forward using the schaefer model
  for (y in 2:nyr) {
    B[y] <- schaefer(B[y-1],C[y-1],K,r)
  }
  
  #return the time series of biomass
  return(B[yrs])
  
  #end function dynamics
}  


# We are going to condition the operating model by estimating the parameters based on the historical biomass index data.  
# 
# To do this we make a function that shows how well the current parameters fit the data, we assume that the observation errors around the true biomass are log-normally distributed.  
# function to calculate the negative log-likelihood
nll <- function(pars,C,U,getq=FALSE) {  #this function takes the parameters, the catches, and the index data
  #sigma <- exp(pars[3])  # additional parameter, the standard deviation of the observation error
  B <- dynamics(pars,C)  #run the biomass dynamics for this set of parameters
  B <- B[-length(B)]
  #Uhat <- exp(pars[4])*B   #calculate the predicted biomass index - here we assume an unbiased absolute biomass estimate
  #print(U)
  #print(B)
  q = exp(sum(log(U/B))/length(U))
  Uhat = q*B
  sigma = sqrt(sum((log(U)-log(q)-log(B))^2, na.rm = TRUE)/length(U))
  
  # obj_fun += ncpue*log(f_sigma) + 0.5*ncpue;
  output <- length(U)*log(sigma) + length(U)/2
  #  output <- -sum(dnorm(log(U),log(Uhat),sigma,log=TRUE),na.rm=TRUE)   #calculate the negative log-likelihood
  ifelse(getq==TRUE,return(q),return(output))
  #end function nll
}


# Function to perform the assessment and estimate the operating model parameters  
# (i.e. to fit the logistic model to abundance data)
assess <- function(catch,index,calc.vcov=FALSE,pars.init) {
  # assess takes catch and index data, initial values for the parameters,
  # and a flag saying whether to compute uncertainty estimates for the model parameters
  
  #fit model
  # optim runs the function nll() repeatedly with differnt values for the parameters,
  # to find the values that give the best fit to the index data
  res <- optim(pars.init,nll,C=catch,U=index,getq = FALSE, method = "BFGS") #,hessian=TRUE)
  
  # store the output from the model fit
  output <- list()
  output$pars <- res$par
  output$q <- nll(res$par, C=catch, U=index, getq = TRUE)
  output$biomass <- dynamics(res$par,catch)
  output$convergence <- res$convergence
  output$nll <- res$value
  if (calc.vcov)
    output$vcov <- solve(res$hessian)
  
  return(output)
  #end function assess
}

## 
## do the (stock complex) management procedure 
##
do_ebfm_mp <- function(settings, assess_results, input) {
  # input is a list with variables
  # Nsp -> number of species
  # complex -> mapping of species to complexes
  #
  # assess_results is the output of a call to run_assessments()
  #
  # settings is a list with info partameterizing the MP
  # useCeiling = "Yes",
  # assessType = "stock complex" or "single species"
  # targetF = 0.75,  target fishing mortality rate relative to FMSY
  # floorB = 0.25,   fraction of historical survey index to use as the single species floors
  # floorOption = "avg status" or "min status", whether to base the floor scalar on the average status within the complex or the worst.
  
  sysspp <- input$Nsp + max(input$complex, na.rm=TRUE) + 1 #this function potentiall uses results of assessments for all levels (singlespecies, complex, and ecosystem)
  refs <- assess_results %>%   #unpack assessment results
    ungroup() %>% 
    mutate(estbio = map(results, "biomass"),
           estbio = map(estbio, ~.[-length(.)]),
           blast = map_dbl(estbio, ~.[length(.)]),
           cfmsy = blast * fmsy,
           ffmsy = map_dbl(data, ~.$catch[length(.$catch)-1]),
           ffmsy = ffmsy/map_dbl(estbio, ~.[length(.)-1])/fmsy,
           bbmsy = blast/bmsy,
           ddmax = map_dbl(data, ~last(.$biomass))/map_dbl(data, ~mean(.$biomass[settings$floorYrs], na.rm = TRUE)), #uses most recent estimated biomass value
           bfloor = ddmax/settings$floorB,
           bfloor = ifelse(bfloor>1,1,bfloor),
           ftarg = settings$targetF*fmsy,  #target F is a fraction of estiamted FMSY
           fuse = case_when( #ramp-based HCR
             bbmsy >= settings$bramp ~ ftarg,
             bbmsy < settings$bramp & bbmsy > settings$blim ~ (settings$fmin*fmsy)+(ftarg-(settings$fmin*fmsy))*(bbmsy-settings$blim)/(settings$bramp-settings$blim),
             bbmsy <= settings$blim ~ settings$fmin*fmsy,
             TRUE ~ -99)
    ) %>% 
    I()
  #if(settings$assessType == "stock complex")
  #refs <- mutate(refs, fuse = ftarg*bfloor) #adjust stock complex Fs based on the floor
  refs <- mutate(refs, cfuse = blast*fuse) %>% #calculate catch advice
    I()
  ceiling_val <- refs$cfmsy[sysspp] #pull out syustem cap (catch at ecosystem FMSY)
  refs <- refs  %>% mutate(ceiling = rep(ceiling_val, nrow(.))) %>%
    I()
  #refs
  complex_res <- refs %>% 
    ungroup() %>% 
    dplyr::filter(isp <= input$Nsp) %>% 
    mutate(complex = input$complex) %>% 
    group_by(complex) %>% 
    summarize(floor_mean = mean(bfloor),
              floor_min = min(bfloor)) %>% 
    # input$floorOption == "avg status" ~ mean(bfloor),
    # input$floorOption == "min status" ~ min(bfloor))) %>%  #,
    #TRUE ~ NA)) %>% 
    #ifelse(input$floorOption == "avg status", 
    I()
  #complex_res
  
  if (settings$assessType == "single species") {
    ss_maxcat <- refs %>% 
      dplyr::filter(isp <= input$Nsp) %>% 
      summarize(totcat = sum(cfuse),
                ceiling = mean(ceiling)) %>% 
      mutate(ceiling_mult = ifelse(totcat/ceiling>1,ceiling/totcat,1)) %>% 
      I()
    if (settings$useCeiling == "No") ss_maxcat$ceiling_mult <- 1
    out_table <- refs %>% 
      mutate(advice = ss_maxcat$ceiling_mult*cfuse) %>% 
      select(isp, fmsy, bmsy, blast, ffmsy, bbmsy, cfmsy, fuse, cfuse, ceiling, advice) %>% 
      #select(isp, fmsy, bmsy, blast, ffmsy, bbmsy, cfmsy) %>% 
      dplyr::filter(isp <= input$Nsp)
    if(settings$useCeiling == "No")
      out_table <- select(out_table, -ceiling)
  }
  
  
  if (settings$assessType == "stock complex") {
    #refs$bfloor
    sc_refs <- refs %>%
      ungroup() %>% 
      dplyr::filter(isp > input$Nsp & isp < sysspp) %>% 
      mutate(bfloor = case_when(
        settings$floorOption == "avg status" ~ complex_res$floor_mean,
        settings$floorOption == "min status" ~ complex_res$floor_min),
        fuse = fuse*bfloor,
        cfuse = blast*fuse) %>% 
      I()
    #sc_refs$bfloor
    
    sc_maxcat <- sc_refs %>% 
      summarize(totcat = sum(cfuse),
                ceiling = mean(ceiling)) %>% 
      mutate(ceiling_mult = ifelse(totcat/ceiling>1,ceiling/totcat,1)) %>% 
      I()
    if (settings$useCeiling == "No") {sc_maxcat$ceiling_mult <- 1}
    out_table <- sc_refs %>% 
      mutate(advice = sc_maxcat$ceiling_mult*cfuse,
             complex = isp - input$Nsp) %>% 
      select(complex, fmsy, bmsy, blast, ffmsy, bbmsy, cfmsy, bfloor, fuse, cfuse, ceiling, advice)
    #select(isp, fmsy, bmsy, blast, ffmsy, bbmsy, cfmsy) %>% 
    if(settings$useCeiling == "No")
      out_table <- select(out_table, -ceiling)
  }
  
  results <- NULL
  results$refs <- refs
  results$out_table <- out_table
  return(results)  
  
}