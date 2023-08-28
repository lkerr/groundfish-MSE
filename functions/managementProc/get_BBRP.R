#' @title Calculate Biomass-Based Reference Points
#'
#'@param parmgt A 1-row data frame of management parameters. The operational
#'         component of parmgt for this function are the (1-row) columns
#'         "BREF_TYP" and "BREF_PAR0". BREF_TYP refers to the type of biomass-
#'         based reference point you want to use and BREF_PAR0 refers to
#'         an associated level for that reference point. Options are:
#' \itemize{
#'   \item{RSSBR - mean recruitment multiplied by SPR at Fmsy or some proxy of SPR at Fmsy
#'               - par is SPR level for Fmsy proxy (e.g. 0.35 for F35%)}
#'   \item{dummy - par is some scalar}
#' }
#' @param parpop A list of population parameters needed to calculate the biomass-based reference point.
#' See get_advice for specific items in parpop (updated by assessment functions e.g. get_WHAM, get_ASAP) 
#' @param parenv
#' @param Rfun_lst
#' @param FBRP
#' @param distillBmsy The name of a function (CANNOT be a string) to aggregate biomass under the particular F policy, default = mean. Since temperature can play a role there may be no equilibrium over the period, so a decision about what function to use for biomass needs to be made (mean, median or a quantile). @seealso \code{\link{get_BmsySim}}
#' @param stockEnv


get_BBRP <- function(parmgt, parpop, parenv, Rfun_lst, FBRP,
                     distillBmsy=mean, stockEnv){

#Assigning misspecified weight-at-age if there is a weight-at-age misspecification
  if (stockEnv$waa_mis=='TRUE'){
    parpop$waa<-stock[[1]]$waa[1,]
  }
  
  if(parmgt$BREF_TYP == 'RSSBR'){

    # There cannot be any forward projections associated with RSSBR. They
    # don't make sense because if that is your assumption about recruitment
    # then biomass in the future won't matter.

    parmgt1 <- list(FREF_PAR0 = FBRP, FREF_TYP = 'SSBR')

    ssbrFmax <- get_perRecruit(parmgt=parmgt1, parpop=parpop,
                               nage=1000, nF=1000, nFrep=100)

    # Load in the recruitment function (recruitment function index is
    # found in the parmgt data frame but the actual functions are from
    # the list Rfun_BmsySim which is created in the processes folder.

    Rfun <- Rfun_lst[[parmgt$RFUN_NM]]

    funR <- Rfun(parpop = parpop,
                 parmgt= parmgt,
                 ny = parmgt$BREF_PAR0)

    B <- ssbrFmax$SSBvalue * funR

    out <- list(RPvalue = B)

  }else if(parmgt$BREF_TYP == 'SIM'){

    # Load in the recruitment function (recruitment function index is
    # found in the parmgt data frame but the actual functions are from
    # the list Rfun_BmsySim which is created in the processes folder.
    
    Rfun <- Rfun_BmsySim[[parmgt$RFUN_NM]]

    SSB <- get_proj(type = 'BREF', parmgt = parmgt, parpop = parpop,
                    parenv = parenv,
                    Rfun = Rfun, F_val = FBRP,
                    ny = 200, # only will be relevant for hindcast version
                    stReportYear = 2,
                    stockEnv = stockEnv)$SSB

    SSBvalue <- distillBmsy(SSB)

    out <- list(RPvalue = SSBvalue)

  }

  return(out)

}
