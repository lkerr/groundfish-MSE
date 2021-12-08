# A placeholder file so R folder required by R package structure in repo.
# The following function is only defined to set up the expected inputs to the master MSE function (currently source runSims.R)

# Here the description of data inputs are described AND all options outlined in detail

#' @param mproc A labeled vector containing the following settings for the management procedure, may be read from mproc.csv file:
#' \itemize{
#'   \item{ASSESSCLASS - }
#'   \item{HCR - A string specifying the harvest control rule to implement from the following:}
#'   \itemize{
#'     \item{"constF" - The harvest control rule is simply a flat line, in other words no matter what in each year F will be determined by the F reference point.}
#'     \item{"simplethresh" - A simple threshold model. If the estimated SSB is larger than the SSB reference point then the advice will be fishing at the F reference point. If the estimated SSB is smaller than the SSB reference point F will be 0.}
#'     \item{"slide" - A sliding control rule.  Similer to simplethresh, except when the estimated SSB is lower than the SSB reference point fishing is reduced though not all the way to zero. Instead, a line is drawn between [SSBRefPoint, FRefPoint] and [0, 0] and the advice is the value for F on that line at the corresponding estimate of SSB.}
#'     \item{"tempslide" - A control rule based on the control rule outlined in the Technical Guidance on the Use of Precautionary Approaches to Implementing National Standard 1 of the MSA (see Gabriel and Mace 1999, Proceedings, 5th NMFS NSAW)}
#'     \item{"pstar" - The P\* method. The aim of this HCR option is to avoid overfishing by accounting for scientific uncertainty with a probabilistic approach. In this scenario, the P\* approach (Prager & Shertzer, 2010) is used to derive target catch. The P\* method derives target catch as a low percentile of projected catch at the OFL, to allow for scientific uncertainty. The distribution of the catch at the OFL was assumed to follow a lognormal distribution with a CV of 1 (Wiedenmann et al., 2016). The target catch will correspond to a probability of overfishing no higher than 50% (P\* <0.5) in accordance with the National Standard 1 guidelines.}
#'     \item{"step" - Step in fishing mortality. If the SSB decreased below the biomass threshold, this HCR uses a target F of 70% FMSY that has recently been applied to New England groundfish as a default Frebuild. If the SSB never decreased below the biomass threshold or increased to over SSBMSY after dropping below the biomass threshold, this HCR uses a target F at the F threshold. This alternative directly emulates an HCR used for some New England groundfish.}
#'   }
#'   \item{FREF_TYP - A string indicating the type of model that should be used to calculate the F reference point, options include:  ??? check not missing info} 
#'   \itemize{
#'     \item{"YPR" - Yield-per-recruit-based reference point, the level of slope of the YPR curve that is x% of the origin slope (e.g. FREF_PAR0 = 0.1 for F_0.1). @seealso \code{\link{get_perRecruit}}. Basically the parameters (par) are just the reference point level.}
#'     \item{"SSBR" - Spawner biomass-per-recruit}
#'     \item{"SPR" - Spawning potential ratio-based reference point. @seealso \code{\link{get_perRecruit}}. Basically the parameters (par) are just the reference point level.}
#'     \item{"Mbased" - Natural mortality-based (data poor) option (see Gabriel and Mace 1999, p.42). In some cases M or some factor of M has been considered as a proxy for Fmsy.}
#'   }
#'   \item{FREF_PAR0 - A proportion describing the F level used for the reference point (e.g., 0.4 for F40% if you are using SPR or 0.1 for F0.1 if you are using YPR)}
#'   \itemize{
#'     \item{If FREF_TYP = "YPR", FREF_PAR0 describes the percent of the YPR curve (e.g. 0.1 for F_0.1)}
#'     \item{If FREF_TYP = "SSBR", FREF_PAR0 sets the desired level fo spawner biomass-per-recruit}
#'     \item{IF FREF_TYP = "SPR", FREF_PAR0 describes the percent SPR (e.g. 0.4 for F40%)}
#'     \item{??? check if Mbased has a par? I think it automatically as a data-limited ref pt calculated to use and thus this would be NA}
#'   }
#'   \item{FREF_PAR1 - }
#'   \item{BREF_TYP - A string indicating the type of biomass-based reference points to be used, options include: ??? check that not missing anything}
#'   \itemize{
#'     \item{"RSSBR" - Mean recruitment multiplied by SPR at Fmsy OR some proxy of SPR at FMSY, requires additional parameter (SPR level for Fmsy proxy)}
#'     \item{"dummy"}
#'   }
#'   \item{BREF_PAR0 - A number describing the associated level for the selected reference point, vary based on reference point selected:}
#'   \itemize{
#'     \item{If BREF_TYP = "RSSBR", BREF_PAR0 = the SPR level for Fmsy proxy (e.g., 0.35 for F35%)}
#'     \item{If BREF_TYP = "dummy", BREF_PAR0 = some scalar}
#'   }
#'   \item{BREF_PAR1 - }
#'   \item{RFUN_NM - }
#'   \item{RPInt - }
#'   \item{AssessFreq - }
#'   \item{ImplementationClass - }
#'   \item{projections - }
#'   \item{rhoadjust - }
#'   \item{mincatch - }
#'   \item{varlimit - }
#'   \item{Lag - }
#'   \item{LandZero - }
#'   \item{CatchZero - }
#'   \item{EconType - }
#'   \item{EconName - }
#'   \item{EconData - }
#'   \item{MultiplierFile - }
#'   \item{OutputPriceFile - }
#'   \item{InputPriceFile - }
#'   \item{ProdEqn - }
#'   \item{ChoiceEqn - }
#' }
#' 
#' @section Parameters currently specified in the modelParameters/stockParameters files
#' @param burnFmsyScalar
#' @param burnFsd
#' @param fage
#' @param page
#' 
#' @section Life history parameters
#' @param laa_par
#' @param laa_typ
#' @param waa_par
#' @param waa_typ
#' @param mat_par
#' @param mat_typ
#' @param M
#' @param M_typ
#' @param init_M
#' @param initN_par
#' @param initN_type
#' @param Rpar
#' @param R_typ
#' @param R_mis
#' @param Rpar_mis
#' 
#' @section Fishery parameters
#' @param qC
#' @param qI
#' @param DecCatch
#' @param selC
#' @param selC_typ
#' 
#' @section Survey parameters
#' @param selI
#' @param selI_typ
#' @param timeI
#' 
#' @section Stock assessment model parameters
#' @param ncaayear
#' @param boundRgLev
#' @param startCV
#' @param caaInScalar
#' @param M_mis A boolean, if TRUE implement misspecification in natural mortality???
#' @param M_mis_val ???
#' @param waa_mis
#' @param R_mis
#' @param R_mis_typ
#' @param Rpar_mis
#' 
#' @section Error parameters
#' @param oe_sumCW
#' @param oe_sumCW_typ
#' @param oe_paaCN
#' @param oe_paaCN_typ
#' @param oe_sumIN
#' @param oe_sumIN_typ A string specifying the type of error to implement
#' \itemize{
#'   \item{"lognorm" - Implements lognormal errors}
#' }
#' @param oe_paaIN
#' @param oe_paaIN_typ
#' \itemize{
#'   \item{"multinomial" - Implements multinomial errors ??? This option requires a single parameter (a number for the effective sample size)}
#' }
#' @param oe_effort
#' @param oe_effort_typ
#' @param highobserrec
#' @param pe_R
#' @param pe_RSA
#' @param pe_IA Parameter associated with oe_sumIN_typ in get_proj.R/get_error_paa
#' @param ie_F
#' @param ie_typ
#' @param ie_bias
#' @param ob_sumCW
#' @param ob_sumIN
#' @param C_mult
#' @param Change_point2
#' @param Change_point_yr
#' @param Change_point3
#' 
#' 
#' 

runSims <- function(mproc = NULL){
  
  #### -- Errors and warnings -- #### - from modelParameters/stockParameters/haddockGB
  if(1.0 %in% c(qI, qC)){
    stop('catchability (qI and qC) must not be exactly one (you can make it
        however close you want though')
  }
}
