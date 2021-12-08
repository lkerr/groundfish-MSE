# Roxygen documentation for global argument: stock
# BE CAUTIOUS WHEN EDITING THIS FILE
# changes will be inherited by all functions that use @template global_stock

#' @param stock A table containing stock inputs ??? Or is this a list as in runSetup.R line 138?
#' @param stock A list of stocks containing the following list items for each species (structured by runSetup.R, combines stockPar from stock files, and stockCont from get_containers.R):
#' \itemize{
#' From stockPar file
#'   \item{oe_effort_typ - A string }
#'   \item{Change_point_yr1 - A year}
#'   \item{pe_RSA - A number}
#'   \item{Change_point_yr2 - A year}
#'   \item{waa_par - A vector of weight-at-age}
#'   \item{initN_par - A named vector containing the following:}
#'   \itemize{
#'     \item{nage}
#'     \item{N0}
#'     \item{F_full}
#'     \item{M}
#'   }
#'   \item{ncaayear - A number}
#'   \item{mat_par - A vector of proportion maturity-at-age ???}
#'   \item{qC - A number}
#'   \item{M_mis - A boolean}
#'   \item{burnFsd - A number}
#'   \item{oe_effort - A number}
#'   \item{page - An age}
#'   \item{startCV - A number}
#'   \item{timeI - A number}
#'   \item{qI - A number}
#'   \item{waa_typ - A string}
#'   \item{selC_typ - A string}
#'   \item{mat_typ - A string}
#'   \item{R_typ - A string}
#'   \item{selI_typ - A string}
#'   \item{pe_IA - A number}
#'   \item{caaInScalar - A number}
#'   \item{laa_par - A named vector containing the following:}
#'   \itemize{
#'     \item{Linf}
#'     \item{K}
#'     \item{t0}
#'     \item{beta1}
#'   }
#'   \item{Rpar - A named vector containing the following:}
#'   \itemize{
#'     \item{SSB_star}
#'     \item{cR}
#'     \item{Rnyr}
#'   }
#'   \item{pe_R}
#'   \item{selC - A vector of catch ??? selectivity-at-age}
#'   \item{stockName - A string specifying the stock name for which the list corresponds}
#'   \item{nage - A number specifying the number of ages}
#'   \item{initN_type - A string}
#'   \item{boundRgLev - A number}
#'   \item{ob_sumCW - A number}
#'   \item{oe_sumCW - A number}
#'   \item{DecCatch - A boolean}
#'   \item{selI - A vector of survey selectivity-at-age}
#'   \item{M - A number for natural mortality}
#'   \item{init_M - A number for initial natural mortality}
#'   \item{oe_paaCN - A number}
#'   \item{oe_paaIn - A number}
#'   \item{M_typ - A string}
#'   \item{R_mis_typ - A string}
#'   \item{laa_typ - A string}
#'   \item{oe_sumCW_typ - A string}
#'   \item{oe_paaIN_typ - A string}
#'   \item{oe_sumIN_typ - A string}
#'   \item{oe_paaCN_typ - A string}
#'   \item{ie_typ - A string}
#'   \item{Change_point_yr - A year}
#'   \item{Change_point2 - A boolean}
#'   \item{burnFmsyScalar - A number}
#'   \item{Change_point3 - A boolean}
#'   \item{Rpar_mis - A named vector containing the following:}
#'   \itemize{
#'     \item{SSB_star}
#'     \item{cR}
#'     \item{Rnyr}
#'   }
#'   \item{waa_mis - A boolean}
#'   \item{R_mis - A boolean}
#'   \item{ie_bias - A number}
#'   \item{C_mult - A number}
#'   \item{fage - A number}
#'   \item{ie_F - A number}
#'   \item{M_mis_val - A number}
#'   \item{ob_sumIN - A number}
#'   \item{oe_sumIN - A number}
#' From setup by get_containers.R and populated during MSE simulation ??? Check this
#' \itemize{
#'   \item{Simulation storage containers}
#'   \itemize{
#'     \item{J1N - A matrix with nyear rows and a column for each age}
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
#' } # End of container description
#' }
#' 
