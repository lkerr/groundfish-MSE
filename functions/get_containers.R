# Script to create containers (necessary because the main
# script uses loops that it fills)

get_containers <- function(stockPar){
  
  yxage = matrix(NA, nrow=nyear, ncol=stockPar$nage)
  yx0 = rep(NA, nyear)
  est = matrix(NA,nyear,106)
  
  nomyear = nyear - (stockPar$ncaayear + fyear + nburn)
  nmproc = nrow(mproc)
  
  save_vector_ann = array(data = NA,
                          dim = c(nyear),
                          dimnames = list(paste0('nyear', 1:nyear)))
  
  save_vector_ann2 = array(data = NA,
                           dim = c(nyear,nyear),
                           dimnames = list(paste0('nyear', 1:nyear),
                                           paste0('nyear', 1:nyear)))
  
  
  # Revised container style (index by rep and year, repeated by mproc when stock object generated for each mproc)
  rep_year_container <- vector(mode='list', length = nyear)
  
  out <- list(
    
    # Containers that save the simulation data
    J1N = yxage,
    CN = yxage,
    CN_temp = yxage,
    CW = yxage,
    IN = yxage,
    laa = yxage,
    waa = yxage,
    Z = yxage,
    slxC = yxage,
    slxI = yxage,
    mat = yxage,
    F_full = yx0,
    F_fullAdvice = yx0,
    ACL = yx0,
    R = yx0,
    Rhat = yx0,
    N=yx0,
    SSB = yx0,
    RPmat = matrix(NA, nrow=nyear, ncol=4,
                   dimnames = list(paste0(1:nyear),
                                   c('FRefP', 'BRefP','FRefPT', 'BRefPT'))),
    natM = yx0,
    
    # catch weight
    sumCW = yx0,
    obs_sumCW = yx0,
    
    # total survey index in numbers
    sumIN = yx0,
    obs_sumIN = yx0,
    
    # total survey index in weight (if obs_sumIW is needed see note in
    # get_indexData comments)
    sumIW = yx0,
    obs_sumIW = yx0,
    
    # catch proportions-at-age
    paaCN = yxage,
    obs_paaCN = yxage,
    
    # survey proportions-at-age
    paaIN = yxage,
    obs_paaIN = yxage,
    
    # Stock assessment model results
    conv_rate = yx0,#MDM
    Mohns_Rho_SSB = yx0,
    Mohns_Rho_F = yx0,#MDM
    Mohns_Rho_R = yx0,
    alphaest = yx0,
    betaest = yx0,
    SSBest = save_vector_ann2,
    Fest = save_vector_ann2,
    Catchest = save_vector_ann2,
    Rest = save_vector_ann2,
    Mest =save_vector_ann2,  #MDM
    
    dn_omyear = paste0('year', 1:nomyear),
    
    omval = list(
      N = save_vector_ann,
      SSB = save_vector_ann,
      R = save_vector_ann,
      F_full = save_vector_ann,
      F_fullAdvice = save_vector_ann,
      ACL = save_vector_ann,
      sumCW = save_vector_ann,
      FPROXY = save_vector_ann,
      SSBPROXY = save_vector_ann,
      FPROXYT = save_vector_ann,
      SSBPROXYT = save_vector_ann,
      SSBRATIO = save_vector_ann,
      SSBRATIOT = save_vector_ann,
      FRATIO = save_vector_ann,
      FRATIOT = save_vector_ann,
      natM = save_vector_ann, #AEW
      conv_rate = save_vector_ann, #MDM
      Mohns_Rho_SSB = save_vector_ann,
      Mohns_Rho_F = save_vector_ann,#MDM
      Mohns_Rho_R = save_vector_ann,#MDM
      alphaest = save_vector_ann,
      betaest = save_vector_ann,
      SSBest = save_vector_ann2,
      Fest = save_vector_ann2,
      Catchest = save_vector_ann2,
      Rest = save_vector_ann2,
      Mest = save_vector_ann2
    ),
    
    om_settings = NULL, # Empty storage for OM settings/values, fill below
    wham_storage = NULL
    
  ) # End definition of "out" (returned object)
  
  # Define om_settings structure
  out$om_settings <- list(om_qI = rep_year_container, # indexed by [[irep]][[iyear]]
                          om_qC = rep_year_container)
  
  assess_vals = list(
    assess_dat=as.data.frame(list(
      Year=c(rep(999,nyear)),
      F=c(rep(999,nyear)),
      R=c(rep(999,nyear)),
      M=c(rep(999,nyear)),
      MSEyr=c(rep(999,nyear)))),
    assess_st_yr=999
  )
  
  # If one of the assessment models is WHAM this storage container will be created for each stock but only populated for those stocks using WHAM
  # All items in this list can be indexed by wham_storage$listObjects[[irep]][[iyr]]
  if("WHAM" %in% mproc[,'ASSESSCLASS']){
    
    store_SSB <- vector(mode='list', length = nyear)
    store_F <- vector(mode='list', length = nyear)
    store_R <- vector(mode='list', length = nyear)
    store_Catch <- vector(mode='list', length = nyear)
    store_FMSY <- rep(NA, nyear) # Single time series since a single value in each year
    store_SSBMSY  <- rep(NA, nyear) # Single time series since a single value in each year
    store_MSY <- rep(NA, nyear) # Single time series since a single value in each year
    store_SelF <- vector(mode='list', length = nyear)
    store_Convergence <- rep(NA, nyear) # Single time series, will only populate years where assessment run
    store_MohnsRho_SSB <- rep(NA, nyear) # Single time series since a single value in each year
    store_MohnsRho_F <- rep(NA, nyear) # Single time series since a single value in each year
    store_MohnsRho_R <- rep(NA, nyear) # Single time series since a single value in each year
    store_M<-vector(mode='list', length = nyear)
    store_alpha<-vector(mode='list', length = nyear)
    store_beta<-vector(mode='list', length = nyear)
    store_pars_q <- vector(mode='list', length = nyear)
    
    wham_storage_temp <- list(
      SSB = store_SSB,
      F = store_F,
      R = store_R,
      Catch = store_Catch,
      FMSY = store_FMSY,
      SSBMSY = store_SSBMSY,
      MSY = store_MSY,
      SelF = store_SelF,
      checkConvergence = store_Convergence,
      MohnsRho_SSB = store_MohnsRho_SSB,
      MohnsRho_F = store_MohnsRho_F,
      MohnsRho_R = store_MohnsRho_R,
      M=store_M,
      alpha=store_alpha,
      beta=store_beta,
      pars_q = store_pars_q
    )
    
    # Replicate for each stock (only populated if assessment uses WHAM), rather than setting multiple rows as for other MSE results above
    out$wham_storage <- wham_storage_temp # rep(list(rlang::duplicate(wham_storage_temp, shallow = FALSE)), nrow(mproc))
  }
  
  return(out)
  
}