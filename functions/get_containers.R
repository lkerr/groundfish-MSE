
# Script to create containers (necessary because the main
# script uses loops that it fills)

get_containers <- function(stockPar){
  
  yxage = matrix(NA, nrow=nyear, ncol=stockPar$nage)
  yx0 = rep(NA, nyear)
  
  nomyear = nyear - (stockPar$ncaayear + fyear + nburn)
  nmproc = nrow(mproc)
  
  save_vector_ann = array(data = NA,
                          dim = c(nrep, nmproc, nyear),
                          dimnames = list(paste0('rep', 1:nrep), 
                                          paste0('mproc', 1:nmproc),
                                          paste0('nyear', 1:nyear)))
  
  out <- list(

    # Containers that save the simulation data
    J1N = yxage,
    CN = yxage,
    CW = yxage,
    IN = yxage,
    IJ1= yxage,
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
    SSB = yx0,
    RPmat = matrix(NA, nrow=nyear, ncol=2,
                   dimnames = list(paste0(1:nyear), 
                                   c('FRefP', 'BRefP'))),
    OFdStatus = yx0,
    mxGradCAA = yx0,
    OFgStatus = yx0,
    
    
    # Containers that have corresponding outputs for the
    # assessment model
    
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
    
    # fishing effort
    effort = yx0,
    obs_effort = yx0,
    
    
    # CAA model results
    relE_qI = yx0,
    relE_qC = yx0,
    relE_selCs0 = yx0,
    relE_selCs1 = yx0,
    relE_ipop_mean = yx0,
    relE_ipop_dev = yx0,
    relE_R_dev = yx0,
    relE_SSB = yx0,
    relE_CW = yx0,
    relE_IN = yx0,
    relE_R = yx0, #AEW
    relE_F = yx0, #AEW
    
    
    # Econ model containers
    # Total Weight of catch
    econCW= yx0, 
    

    # container to hold operating/assessment model results
    # (operating model-assessment model comparison)
    
    
    
    dn_rep = paste0('rep', 1:nrep),
    dn_omyear = paste0('year', 1:nomyear),
    dn_mproc = paste0('mproc', 1:nmproc),
    
    
    # # array template for scalar conainer
    # save_scalar <- array(data = NA,
    #                      dim = c(nrep, nmproc, nomyear, 2),
    #                      dimnames = list(paste0('rep', 1:nrep),
    #                                      paste0('mproc', 1:nmproc),
    #                                      paste0('omyear', 1:nomyear),
    #                                      c('val', 'caahat')))
    
    # array template for vector conainer
    # save_vector_ann <- array(data = NA,
    #                          dim = c(nrep, nmproc, nomyear, ncaayear, 2),
    #                          dimnames = list(paste0('rep', 1:nrep), 
    #                                          paste0('mproc', 1:nmproc),
    #                                          paste0('omyear', 1:nomyear),
    #                                          paste0('caayear', 1:ncaayear),
    #                                          c('val', 'caahat')))
    
    # save_vector_age <- array(data = NA,
    #                          dim = c(nrep, nmproc, nomyear, nage, 2),
    #                          dimnames = list(paste0('rep', 1:nrep), 
    #                                          paste0('mproc', 1:nmproc),
    #                                          paste0('omyear', 1:nomyear),
    #                                          paste0('caaage', 1:nage),
    #                                          c('val', 'caahat')))
    
    # # array template for matrix conainer
    # save_matrix <- array(data = NA,
    #                      dim = c(nrep, nmproc, nomyear, ncaayear, nage, 2),
    #                      dimnames = list(paste0('rep', 1:nrep), 
    #                                      paste0('mproc', 1:nmproc),
    #                                      paste0('omyear', 1:nomyear),
    #                                      paste0('caayear', 1:ncaayear),
    #                                      paste0('caaage', 1:nage),
    #                                      c('val', 'caahat')))
    
    # oacomp <- list(
    # 
    #   # model specifications
    #   mspecs = c(
    #                 # index bounds
    #                 ncaayear = ncaayear,
    #                 nage = nage,
    # 
    #                 # survey timing
    #                 timeI = timeI
    #             ),
    # 
    #   sumCW = save_vector_ann,
    #   paaCN = save_matrix,
    #   sumIN = save_vector_ann,
    #   paaIN = save_matrix,
    #   # effort = save_vector_ann,
    #   # laa = save_matrix,
    #   # waa = save_matrix,
    # 
    #   # oe_paaCN = save_scalar,
    #   # oe_paaIN = save_scalar,
    # 
    #   # M = save_matrix,
    #   ## R_devs have nyear-1 entries
    #   # R_dev = array(data = NA,
    #   #               dim = c(nrep, nmproc, nomyear, ncaayear-1, 2),
    #   #               dimnames = list(paste0('rep', 1:nrep), 
    #   #                               paste0('mproc', 1:nmproc),
    #   #                               paste0('omyear', 1:nomyear),
    #   #                               paste0('caayear', 1:(ncaayear-1)),
    #   #                               c('val', 'caahat'))),
    #   # log_ipop_mean = save_scalar,
    #   # ipop_dev = save_vector_age,
    # 
    #   # oe_sumCW = save_scalar,
    #   # oe_sumIN = save_scalar,
    #   # pe_R = save_scalar,
    # 
    #   ## adaptive length for selectivity vector in case the function
    #   ## changes 
    #   # selC = array(data = NA,
    #   #              dim = c(nrep, nmproc, nomyear, length(selC), 2),
    #   #              dimnames = list(paste0('rep', 1:nrep),
    #   #                              paste0('mproc', 1:nmproc),
    #   #                              paste0('omyear', 1:nomyear),
    #   #                              paste0('s', 1:length(selC)),
    #   #                              c('val', 'caahat'))),
    #   qC = save_scalar,
    #   # qI = save_scalar,
    #   ## ... currently no selI parameters to go from so just use 1:2.
    #   # selI = array(data = NA,
    #   #              dim = c(nrep, nmproc, nomyear, 2, 2),
    #   #              dimnames = list(paste0('rep', 1:nrep),
    #   #                              paste0('mproc', 1:nmproc),
    #   #                              paste0('omyear', 1:nomyear),
    #   #                              paste0('s', 1:2),
    #   #                              c('val', 'caahat'))),
    #   slxC = save_matrix,
    #   F_full = save_vector_ann,
    #   F = save_matrix,
    #   # Z = save_matrix,
    #   R = save_vector_ann,
    #   # J1N = save_matrix,
    #   SSB = save_vector_ann
    #   # CN = save_matrix,
    #   # IN = save_matrix,
    #   
    #   # NLL = save_scalar,
    #   # NLL_sumCW = save_scalar,
    #   # NLL_sumIN = save_scalar,
    #   # NLL_R_dev = save_scalar,
    #   # NLL_paaCN = save_scalar,
    #   # NLL_paaIN = save_scalar
    # )
    
    
    
    # Version 2 of saving a vector ... this one with only a 
    # placeholder for the value, not the estimate and no CAA year.
    # array template for vector conainer
    
    # First year to output for saving OMresults
    # nomyear <- nyear#ncaayear + fyear + nburn + rburn
    
    
    # save_2xmatrix_ann <- array(data = NA,
    #                            dim = c(nrep, nmproc, nyear-(fmyearIdx-1)+1, 2),
    #                            dimnames = list(paste0('rep', 1:nrep),
    #                                            paste0('mproc', 1:nmproc),
    #                                            paste0('nyear', 1:(nyear-
    #                                                                 (fmyearIdx-1)+1)),
    #                                            c('FRefP', 'BRefP')))
    
    
    
    omval = list(
      SSB = save_vector_ann,
      R = save_vector_ann,
      F_full = save_vector_ann,
      F_fullAdvice = save_vector_ann,
      ACL = save_vector_ann,
      econCW= save_vector_ann, 
      sumCW = save_vector_ann,
      annPercentChange = save_vector_ann, #cheap ... not really vector.
      meanSizeCN = save_vector_ann,
      meanSizeIN = save_vector_ann,
      FPROXY = save_vector_ann,
      SSBPROXY = save_vector_ann,
      OFdStatus = save_vector_ann,
      mxGradCAA = save_vector_ann,
      relE_qI = save_vector_ann,
      relE_qC = save_vector_ann,
      relE_selCs0 = save_vector_ann,
      relE_selCs1 = save_vector_ann,
      relE_ipop_mean = save_vector_ann,
      relE_ipop_dev = save_vector_ann,
      relE_R_dev = save_vector_ann,
      relE_SSB = save_vector_ann,
      relE_CW = save_vector_ann,
      relE_IN = save_vector_ann,
      relE_R = save_vector_ann, #AEW
      relE_F = save_vector_ann, #AEW
      OFgStatus = save_vector_ann #AEW
    )
    
  )
  
  return(out)

}

