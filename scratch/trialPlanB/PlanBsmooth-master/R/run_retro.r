#' Wrapper function to conduct retrospective analysis.
#' 
#' Conducts standard retrospective analysis on predicted biomass index, inlcuding reporting Mohn's rho. Also examines retrospective analysis of multiplier (inclusing years prior to terminal year).
#' @param dat data frame of Year and avg (the biomass index)
#' @param od output directory where plots are saved (default=working directory)
#' @param my.title title for time series plot with loess smooth (default = "")
#' @param terminal.year last year used in smooth (allows easy retro analysis) (default = NA = most recent)
#' @param nyears number of years to use in loess (default = 33)
#' @param loess.span proportion time series used in smoothing (default = NA, calculates span=9.9/nyears)
#' @param npeels how many years to remove in retrospective analysis
#' @param saveretroplot true/false flag to save retrospective plot to od (default=FALSE)
#' @export

RunRetro <- function(dat,
                     od            = ".\\",
                     my.title      = "",
                     terminal.year = NA,
                     nyears        = 33,
                     loess.span    = NA,
                     npeels        = 7,
                     saveretroplot = FALSE){
  
  # determine ending years
  if(is.na(terminal.year)) terminal.year <- max(dat$Year, na.rm=T)
  term.years <- seq(terminal.year, terminal.year - npeels, -1)

  # loop through peels
  res <- list()
  for (ipeel in 1:(npeels+1)){
    res[[ipeel]] <- ApplyPlanBsmooth(dat,
                                     od            = od,
                                     my.title      = my.title,
                                     terminal.year = term.years[ipeel],
                                     nyears        = nyears,
                                     loess.span    = loess.span,
                                     saveplots     = FALSE)
  }
  
  # get data for retro plot
  ribbon <- data.frame(Year = res[[1]]$dat.use$Year,
                       avg  = res[[1]]$dat.use$avg,
                       pred = res[[1]]$pred_fit$fit,
                       loci = res[[1]]$pred_fit$fit - 1.96 * res[[1]]$pred_fit$se.fit,
                       hici = res[[1]]$pred_fit$fit + 1.96 * res[[1]]$pred_fit$se.fit,
                       peel = 0)
  for (ipeel in 2:(npeels+1)){
    rpeel <- data.frame(Year = res[[ipeel]]$dat.use$Year,
                        avg  = res[[ipeel]]$dat.use$avg,
                        pred = res[[ipeel]]$pred_fit$fit,
                        loci = res[[ipeel]]$pred_fit$fit - 1.96 * res[[ipeel]]$pred_fit$se.fit,
                        hici = res[[ipeel]]$pred_fit$fit + 1.96 * res[[ipeel]]$pred_fit$se.fit,
                        peel = ipeel - 1)
    ribbon <- rbind(ribbon, rpeel)
  }

  ribbon <- mutate(ribbon, loci0 = ifelse(loci < 0, 0, loci)) # to allow ggplot to show CI when low < 0
  
  # compute Mohn's rho for predicted biomass index
  rho.vals.B <- rep(NA, npeels)
  for (ipeel in 1:npeels){
    jval <- ipeel + 1
    myyear <- term.years[jval]
    check.val <- filter(ribbon, Year == myyear, peel == ipeel)$pred
    term.val <- filter(ribbon, Year == myyear, peel == 0)$pred
    if (length(check.val) == 1 & length(term.val) == 1){
      rho.vals.B[ipeel] <- (check.val - term.val) / term.val
    }
  }
  rho.B <- mean(rho.vals.B, na.rm=TRUE)
  
  # make retro plot for predicted biomass index
  year.range <- filter(ribbon, peel == 0)$Year
  
  ribbon <- filter(ribbon, Year >= min(year.range), Year <= max(year.range))
  
  retro_plot_biomass <- ggplot(ribbon, aes(x=Year, y=avg)) +
    geom_point() +
    geom_ribbon(data=filter(ribbon, peel == 0), 
                aes(x=Year, ymin=loci0, ymax=hici), fill="grey50", alpha=0.3) +
    geom_line(data=ribbon, aes(x=Year, y=pred, color=as.factor(peel)), size=1.3) +
    scale_y_continuous(expand = c(0,0), limits = c(0, NA)) +
    ylab("Biomass Index") +
    labs(title = my.title, subtitle = paste0("Mohn's rho =",round(rho.B,3))) +
    labs(color="Peel") +
    theme_bw()
  
  print(retro_plot_biomass)
  if(saveretroplot) savePlot(paste0(od,"retro_plot_biomass.png"), type='png')
  
  # compute retro analysis of multiplier estimates
  mult.ribbon <- data.frame(Year = integer(),
                            peel = integer(),
                            mult = double())
  start.year <- max(year.range) - npeels - 3
  for (j in start.year:max(year.range)){
    mreg.dat <- filter(ribbon, Year >= (j - 2), Year <= j, peel == 0)
    if(dim(mreg.dat)[1] >= 2){
      llr_fit <- lm(log(pred) ~ Year, data=mreg.dat)
      mult <- exp(llr_fit$coefficients[2])
      mult.ribbon.step <- data.frame(Year = j,
                                     peel = 0,
                                     mult = mult)
      mult.ribbon <- rbind(mult.ribbon, mult.ribbon.step)
    }
  }
  for (ipeel in 1:npeels){
    for (j in start.year:term.years[(ipeel+1)]){
      mreg.dat <- filter(ribbon, Year >= (j - 2), Year <= j, peel == ipeel)
      if(dim(mreg.dat)[1] >= 2){
        llr_fit <- lm(log(pred) ~ Year, data=mreg.dat)
        mult <- exp(llr_fit$coefficients[2])
        mult.ribbon.step <- data.frame(Year = j,
                                       peel = ipeel,
                                       mult = mult)
        mult.ribbon <- rbind(mult.ribbon, mult.ribbon.step)
      }
    }
  }
  
  # make retro plot for multiplier
  retro_plot_multiplier <- ggplot(mult.ribbon, aes(x=Year, y=mult, color=as.factor(peel))) +
    geom_line() +
    geom_point() +
    scale_x_continuous(labels=seq(start.year,max(year.range)),breaks=seq(start.year,max(year.range))) +
    ylab("Multiplier") +
    labs(title = my.title) +
    labs(color="Peel") +
    theme_bw()
  
  print(retro_plot_multiplier)
  if(saveretroplot) savePlot(paste0(od,"retro_plot_multiplier.png"), type='png')

  # define list of returned variables and plots
  retres <- list(ribbon                = ribbon,
                 rho.vals.B            = rho.vals.B,
                 rho.B                 = rho.B,
                 mult.ribbon           = mult.ribbon,
                 retro_plot_biomass    = retro_plot_biomass,
                 retro_plot_multiplier = retro_plot_multiplier)
  
  return(retres)
}  
