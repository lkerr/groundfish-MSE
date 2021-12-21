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
#'   \item{EconData - Full file path to folder containing annual targeting data files (labeled "####.Rds" for each year ####). !!! This is a change from only providing the file name to specifying the full path to folder}
#'   \item{MultiplierFile - Full file path for multiplier data containing columns for???}
#'   \item{OutputPriceFile - Full file path for output price data containing columns for???}
#'   \item{InputPriceFile - Full file path for imput price data containing columns for ???}
#'   \item{ProdEqn - A string specifying the production equation to use (see also setupEconType), options include:}
#'   \itemize{
#'     \item{"pre" - Use the following production variables: "log_crew","log_trip_days","primary","secondary", "log_trawl_survey_weight","constant"}
#'     \item{"post" - Use the following production variables: "log_crew","log_trip_days","primary","secondary", "log_trawl_survey_weight","log_sector_acl", "constant"}
#'   }
#'   \item{ChoiceEqn - A string specifying the species stock equation and choice equation to use (see also setupEconType), options include:}
#'   \itemize{
#'     \item{"pre" - Use the following stock equation: "exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season"}
#'     \item{"pre" - Use the following choice equation: "wkly_crew_wage", "len", "fuelprice", "fuelprice_len"}
#'     \item{"post" - Use same stock and choice equations as for "pre"}
#'   }
#' }
