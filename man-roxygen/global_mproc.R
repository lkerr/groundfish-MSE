# Roxygen documentation for global argument: mproc
# BE CAUTIOUS WHEN EDITING THIS FILE
# changes will be inherited by all functions that use @template global_mproc

# This is a simplified version of the documentation and describes the general structure of mproc but does not list all management options
# For full documentation of options see runSims() documentation and/or the written manual

#' @param mproc A labeled vector containing the following settings for the management procedure, @seealso \code{\link{runSims}} for full description of management options: 
#' \itemize{
#'   \item{ASSESSCLASS - A string indicating the assessment model to implement, options include:}
#'   \itemize{
#'     \item{"CAA" - Implement catch-at-age model provided in package}
#'     \item{"PLANB" - Implement planB approach !!!}
#'     \item{"ASAP" - Implement Age-Structured Assessment Program !!!}
#'     \item{"WHAM" - Implement Woods Hole Assessment Model}
#'   }
#'   \item{HCR - }
#'   \item{FREF_TYP - }
#'   \item{FREF_PAR0 - }
#'   \item{FREF_PAR1 - }
#'   \item{BREF_TYP - }
#'   \item{BREF_PAR0 - }
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
