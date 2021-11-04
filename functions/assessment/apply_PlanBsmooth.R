#' @title  Apply the Plan B Smooth Approach
#' @description Smooths data (Year and Biomass Index) using loess, applies log linear regression to most recent three years, and retransforms back to estimate multiplier for catch advice.
#'
#' @param dat A data frame of Year and avg (the biomass index)
#' @param od A string specifying the output directory where plots are saved, default=working directory.
#' @param my.title A string specifying the title for time series plot with loess smooth, default = "".
#' @param terminal.year A number for the last year used in smooth (allows easy retro analysis), default = NA uses the most recent year.
#' @param nyears A number of years to use in loess, default = 33.
#' @param loess.span proportion time series used in smoothing, default = NA, calculates span=9.9/nyears.
#' @param saveplots A boolean flag, if TRUE save output to od, default=FALSE.
#' @param showplots A boolean flag, if TRUE display plots in window, default=TRUE.
#' @param nameplots A string to be added to start of saved files, default="", spaces not recommended.
#' 
#' @return A list containing the following:
#' \itemize{
#'   \item{dat.use}
#'   \item{lfit}
#'   \item{pred_fit}
#'   \item{reg.use}
#'   \item{llr_fit}
#'   \item{multiplier}
#'   \item{tsplot}
#' }
#' 
#' @family managementProcedure stockAssess
#' 
#' @export

ApplyPlanBsmooth <- function(dat,
                             od            = ".\\",
                             my.title      = "",
                             terminal.year = NA,
                             nyears        = 33,
                             loess.span    = NA,
                             saveplots     = FALSE,
                             showplots     = TRUE,
                             nameplots     = ""){
  
  # select data to use
  if(is.na(terminal.year)) terminal.year <- max(dat$Year, na.rm=T)
  dat.use <- filter(dat, Year <= terminal.year, Year >= (terminal.year - nyears + 1)) %>%
    drop_na()  # removes years with missing index values
  nyears <- max(dat.use$Year) - min(dat.use$Year) + 1 # in case fewer years than (e.g., during retro)

  # apply loess 
  if(is.na(loess.span)) loess.span <- 9.9 / nyears
  lfit <- loess(data=dat.use, avg ~ Year, span=loess.span)
  pred_fit <- predict(lfit, se=TRUE)
  
  # get last three predicted values
  reg.dat <- data.frame(Year = dat.use$Year,
                        pred = pred_fit$fit)
  reg.years <- seq(terminal.year - 2, terminal.year)
  reg.use <- filter(reg.dat, Year %in% reg.years, pred > 0)
  
  # add warning message if recent three year regression has less than three years
  if(dim(reg.use)[1] != 3){
    print("the log-linear regression to estimate the multiplier uses less than 3 years")
  }
  
  # trap holes in time series resulting in 0 or 1 data point for regression to avoid program crashing
  if (dim(reg.use)[1] <= 1){
    llr_fit <- NA
    llr_fit.df <- data.frame(Year  = integer(),
                             llfit = double())
    multiplier <- NA
    round_multiplier <- "NA"
  }
  
  if (dim(reg.use)[1] >= 2){
    # log linear regression of last three loess predicted values
    llr_fit <- lm(log(pred) ~ Year, data=reg.use)
    llr_fit.df <- data.frame(Year  = reg.use$Year,
                             llfit = exp(predict(llr_fit)))
    
    # convert back to regular scale
    multiplier <- as.numeric(exp(llr_fit$coefficients[2]))
    round_multiplier <- round(multiplier, 3)
  }
  
  # make plot
  ribbon <- data.frame(Year = dat.use$Year,
                       avg  = dat.use$avg,
                       pred = pred_fit$fit,
                       loci = pred_fit$fit - 1.96 * pred_fit$se.fit,
                       hici = pred_fit$fit + 1.96 * pred_fit$se.fit)
  if(saveplots) write.csv(ribbon, paste0(od, nameplots, "PlanBsmooth_table.csv"), row.names = FALSE)
    
  ribbon <- mutate(ribbon, loci0 = ifelse(loci < 0, 0, loci)) # to allow ggplot to show CI when low < 0

  tsplot <- ggplot(ribbon, aes(x=Year, y=avg)) +
    geom_point() +
    geom_ribbon(aes(x=Year, ymin=loci0, ymax=hici), fill="grey50", alpha=0.3) +
    geom_line(aes(x=Year, y=pred), color="blue", size=1.3) +
    geom_line(data=llr_fit.df, aes(x=Year, y=llfit), color="red", size=1.3, linetype="dashed") +
    scale_y_continuous(expand = c(0,0), limits = c(0, NA)) +
    ylab("Biomass Index") +
    labs(title = my.title, subtitle = paste0("Multiplier = ", round_multiplier)) +
    theme_bw()
  
  if(showplots==TRUE) print(tsplot)
  if(saveplots) ggsave(paste0(od, nameplots, "time_series_with_loess_smooth.png"), tsplot)
  

  # list of results
  res <- list()
  res$dat.use    <- dat.use
  res$lfit       <- lfit
  res$pred_fit   <- pred_fit
  res$reg.use    <- reg.use
  res$llr_fit    <- llr_fit
  res$multiplier <- multiplier
  res$tsplot     <- tsplot
  
  return(res)

}
