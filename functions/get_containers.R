#' @title Get storage containers
#' @description Create containers (necessary because the main script uses loops that it fills) ??? Does this mean the main loop fills these containers?
#' 
#' @template global_stockPar
#' @template global_nyear
#' @template global_fyear
#' @template global_nburn
#' @template global_mproc
#' @template global_nrep
#' 
#' @return A list containing storage containers for the following: ??? May want to describe what is stored in each matrix
#' \itemize{
#'   \item{Simulation storage containers}
#'   \itemize{
#'     \item{J1N - A matrix with nyear rows and a column for each age for abundance from the operating model}
#'     \item{CN - A matrix with nyear rows and a column for each age}
#'     \item{CN_temp - A matrix with nyear rows and a column for each age}
#'     \item{codCW - A matrix with nyear rows and a column for each age ??? project specific?}
#'     \item{codCW2 - A vector of length nyear ??? project specific}
#'     \item{CW - A matrix with nyear rows and a column for each age}
#'     \item{IN - A matrix with nyear rows and a column for each age}
#'     \item{IJ1 - A matrix with nyear rows and a column for each age}
#'     \item{laa - A matrix with nyear rows and a column for each age}
#'     \item{waa - A matrix with nyear rows and a column for each age}
#'     \item{Z - A matrix with nyear rows and a column for each age},
#'     \item{slxC - A matrix with nyear rows and a column for each age}
#'     \item{slxI - A matrix with nyear rows and a column for each age}
#'     \item{mat - A matrix with nyear rows and a column for each age}
#'     \item{F_full - A vector of length nyear}
#'     \item{F_fullAdvice - A vector of length nyear}
#'     \item{ACL - A vector of length nyear}
#'     \item{R - A vector of length nyear}
#'     \item{Rhat - A vector of length nyear}
#'     \item{N - A vector of length nyear}
#'     \item{SSB - A vector of length nyear}
#'     \item{RPmat - A matrix with nyear rows and 6 columns}
#'     \item{OFdStatus - A vector of length nyear}
#'     \item{mxGradCAA - A vector of length nyear}
#'     \item{OFgStatus - A vector of length nyear}
#'     \item{natM - A vector of length nyear}
#'   }
#'   \item{Storage containers that have corresponding outputs for the assessment model}
#'   \itemize{
#'     \item{sumCW - Catch weight, a vector of length nyear}
#'     \item{obs_sumCW - Observed catch weight, a vector of length nyear}
#'     \item{sumIN - Survey index in numbers, a vector of length nyear}
#'     \item{obs_sumIN - Observed survey index in numbers, a vector of length nyear}
#'     \item{SumIW - Survey index in weight, a vector of length nyear}
#'     \item{obs_sumIW - Observed survey index in weight, a vector of length nyear}
#'     \item{paaCN - Catch proportions-at-age, a matrix with nyear rows and a column for each age}
#'     \item{obs_paaCN - Observed catch proportions-at-age, a matrix with nyear rows and a column for each age}
#'     \item{paaIN - Survey proportions-at-age, a matrix with nyear rows and a column for each age}
#'     \item{obs_paaIN - Observedurvey proportions-at-age, a matrix with nyear rows and a column for each age}
#'     \item{effort - Fishing effort, a vector of length nyear}
#'     \item{obs_effort - Observed fishing effort, a vector of length nyear}
#'   }
#'   \item{Stock assessment model results storage containers}
#'   \itemize{
#'     \item{relE_qI - A vector of length nyear}
#'     \item{relE_qC - A vector of length nyear}
#'     \item{relE_selCs0 - A vector of length nyear}
#'     \item{relE_selCs1 - A vector of length nyear}
#'     \item{relE_ipop_mean - A vector of length nyear}
#'     \item{relE_ipop_dev - A vector of length nyear}
#'     \item{relE_R_dev - A vector of length nyear}
#'     \item{relE_SSB - A vector of length nyear}
#'     \item{relE_N - A vector of length nyear}
#'     \item{relE_CW - A vector of length nyear}
#'     \item{relE_IN - A vector of length nyear}
#'     \item{relE_R - A vector of length nyear}
#'     \item{relE_F - A vector of length nyear}
#'     \item{SSB_cur - A vector of length nyear}
#'     \item{conv_rate - A vector of length nyear}
#'     \item{Mohns_Rho_SSB - A vector of length nyear}
#'     \item{Mohns_Rho_N - A vector of length nyear}
#'     \item{Mohns_Rho_F - A vector of length nyear}
#'     \item{Mohns_Rho_R - A vector of length nyear}
#'     \item{mincatchcon - A vector of length nyear}
#'     \item{relTermE_SSB - A number}
#'     \item{relTermE_CW - A number}
#'     \item{relTermE_IN - A number}
#'     \item{relTermE_qI - A number}
#'     \item{relTermE_R - A number}
#'     \item{relTermE_F - A number}
#'     \item{SSBest - A matrix with nyear rows and 54 columns}
#'     \item{Fest - A matrix with nyear rows and 54 columns}
#'     \item{Catchest - A matrix with nyear rows and 54 columns}
#'     \item{Rest - A matrix with nyear rows and 54 columns}
#'   }
#'   \item{Economic model storage containers}
#'   \itemize{
#'     \item{econCW - A vector of length nyear}
#'   }
#'   \item{Operating and assessment model comparison storage containers}
#'   \itemize{
#'     \item{dn_rep - A nrep length vector of strings describing the rep number}
#'     \item{dn_omyear - A nomyear length vector of strings describing the OM year}
#'     \item{dn_mproc - A nmproc length vector of strings describing the mproc number}
#'     \item{omval - A list of the following}
#'     \itemize{
#'       \item{N - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{SSB - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{R - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{F_full - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{F_fullAdvice - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{ACL - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{econCW - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{sumCW - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{annPercentChange - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{meanSizeCN - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{meanSizeIn - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{FPROXY - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{SSBPROXY - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{FPROXYT - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{SSBPROXYT - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{FPROXYT2 - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{SSBPROXYT2 - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{SSBRATIO - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{SSBRATIOT - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{SSBRATIOT2 - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{FRATIO - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{FRATIOT - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{FRATIOT2 - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{OFdStatus - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{mxGradCAA - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_qI - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_qC - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_selCs0 - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_selCs1 - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_ipop_mean - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_ipop_dev - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_R_dev - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_SSB - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_N - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_CW - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_IN - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_R - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relE_F - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{OFgStatus - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{SSB_cur - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{natM - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{conv_rate - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{Mohns_Rho_SSB - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{Mohns_Rho_N - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{Mohns_Rho_F - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{Mohns_Rho_R - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{mincatchcon - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relTermE_SSB - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relTermE_CW - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relTermE_IN - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relTermE_qI - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relTermE_R - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{relTermE_F - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{SSBest - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{Fest - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{Catchest - A nyear length array of matrices with nrep rows and nmproc columns}
#'       \item{Rest - A nyear length array of matrices with nrep rows and nmproc columns}
#'     }
#'   }
#' }
#' 
#' @family setup
#' 

get_containers <- function(stockPar,
                           nyear,
                           fyear,
                           nburn,
                           mproc,
                           nrep = 2){
  
  yxage = matrix(NA, nrow=nyear, ncol=stockPar$nage)
  yx0 = rep(NA, nyear)
  est = matrix(NA,nyear,54) #??? Why 54? should this be an argument passed to the function?
  
  nomyear = nyear - (stockPar$ncaayear + fyear + nburn)
  nmproc = nrow(mproc)
  
  save_vector_ann = array(data = NA,
                          dim = c(nrep, nmproc, nyear),
                          dimnames = list(paste0('rep', 1:nrep), 
                                          paste0('mproc', 1:nmproc),
                                          paste0('nyear', 1:nyear)))
  # List of storage containers
  out <- list(

    # Containers that save the simulation data
    J1N = yxage,
    CN = yxage,
    CN_temp = yxage,
    codCW = yxage,
    codCW2 = yx0,
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
    N=yx0,
    SSB = yx0,
    RPmat = matrix(NA, nrow=nyear, ncol=6,
                   dimnames = list(paste0(1:nyear), 
                                   c('FRefP', 'BRefP','FRefPT', 'BRefPT','FRefPT2', 'BRefPT2'))),
    OFdStatus = yx0,
    mxGradCAA = yx0,
    OFgStatus = yx0,
    natM = yx0,
    
    # Containers that have corresponding outputs for the assessment model
    
    # Catch weight
    sumCW = yx0,
    obs_sumCW = yx0,
    
    # Total survey index in numbers
    sumIN = yx0,
    obs_sumIN = yx0,
    
    # Total survey index in weight (if obs_sumIW is needed see note in get_indexData comments)
    sumIW = yx0,
    obs_sumIW = yx0,
    
    # Catch proportions-at-age
    paaCN = yxage,
    obs_paaCN = yxage,
    
    # Survey proportions-at-age
    paaIN = yxage,
    obs_paaIN = yxage,
    
    # Fishing effort
    effort = yx0,
    obs_effort = yx0,
    
    # Stock assessment model results
    relE_qI = yx0,
    relE_qC = yx0,
    relE_selCs0 = yx0,
    relE_selCs1 = yx0,
    relE_ipop_mean = yx0,
    relE_ipop_dev = yx0,
    relE_R_dev = yx0,
    relE_SSB = yx0,
    relE_N= yx0,
    relE_CW = yx0,
    relE_IN = yx0,
    relE_R = yx0, #AEW
    relE_F = yx0, #AEW
    SSB_cur = yx0, #AEW
    conv_rate = yx0,#MDM
    Mohns_Rho_SSB = yx0,
    Mohns_Rho_N = yx0,#MDM
    Mohns_Rho_F = yx0,#MDM
    Mohns_Rho_R = yx0,#MDM
    mincatchcon = yx0, #MDM
    relTermE_SSB = NA,#MDM
    relTermE_CW = NA,#MDM
    relTermE_IN = NA,#MDM
    relTermE_qI = NA,#MDM
    relTermE_R = NA,#MDM
    relTermE_F = NA,
    SSBest = est, 
    Fest = est, 
    Catchest = est, 
    Rest = est,
    
    # Econ model containers
    # Total Weight of catch
    econCW= yx0, 
    
    # Container to hold operating/assessment model results
    # (operating model-assessment model comparison)
    
    dn_rep = paste0('rep', 1:nrep),
    dn_omyear = paste0('year', 1:nomyear),
    dn_mproc = paste0('mproc', 1:nmproc),
  
    omval = list(
      N = save_vector_ann,
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
      FPROXYT = save_vector_ann,
      SSBPROXYT = save_vector_ann,
      FPROXYT2 = save_vector_ann,
      SSBPROXYT2 = save_vector_ann,
      SSBRATIO = save_vector_ann,
      SSBRATIOT = save_vector_ann,
      SSBRATIOT2 = save_vector_ann,
      FRATIO = save_vector_ann,
      FRATIOT = save_vector_ann,
      FRATIOT2 = save_vector_ann,
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
      relE_N = save_vector_ann,
      relE_CW = save_vector_ann,
      relE_IN = save_vector_ann,
      relE_R = save_vector_ann, #AEW
      relE_F = save_vector_ann, #AEW
      OFgStatus = save_vector_ann, #AEW
      SSB_cur = save_vector_ann, #AEW
      natM = save_vector_ann, #AEW
      conv_rate = save_vector_ann, #MDM
      Mohns_Rho_SSB = save_vector_ann,
      Mohns_Rho_N = save_vector_ann,#MDM
      Mohns_Rho_F = save_vector_ann,#MDM
      Mohns_Rho_R = save_vector_ann,#MDM
      mincatchcon = save_vector_ann, #MDM
      relTermE_SSB = save_vector_ann,#MDM
      relTermE_CW = save_vector_ann,#MDM
      relTermE_IN = save_vector_ann,#MDM
      relTermE_qI = save_vector_ann,#MDM
      relTermE_R = save_vector_ann,#MDM
      relTermE_F = save_vector_ann,
      SSBest = est,
      Fest = est,
      Catchest = est,
      Rest = est
    ) # End OM list
    
  ) # End container list
  
  return(out)
}
