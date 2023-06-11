get_perfmetrics <- function(results, complexes = NULL, settings = list(assessType = "stock complex")) {
  #takes a results object and calculates the key metrics
  library(tidyverse)
  library(janitor)
  #library(ggdist)
  
#  settings <- NULL
#  settings$assessType = "stock complex"
#  results <- readRDS("~/research/groundfish-MSE/results_2023-06-11-13-20-09/sim/mpres_stock_complex.rds")
  complexes <- tibble(isp = 1:10,
                      complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2))
  
  # fleet_sp <- tibble(species = 1:10,
  #                    fleet = c(1,2,2,rep(1,7)))
  
  #get tables of time series by simulation
  mse_results <- get_mse_results(results = results, complexes = complexes, settings = settings)
  #mse_results$sp_results
  #mse_results$fleet_catch
  
  #calculate metrics in both short and long-term
  yr_range <- list(short = 43:45,
                   long = 43:48)
  metric_calcs <- map(yr_range, ~calc_metrics(mse_results, yrs = .))
  metrics <- map_dfr(metric_calcs, function(x) x$metrics, .id = "time")
  
  median_metrics <- metrics %>% 
    group_by(metric) %>% 
    summarize(value = median(value, na.rm = TRUE),
              .groups = "drop") %>% 
    I()
  
  sp_names <- tibble(species = 1:14, species_name=factor(c(
    "Atlantic_cod",
    "Atlantic_herring",
    "Atlantic_mackerel",
    "Goosefish",
    "Haddock",
    "Silver_hake",
    "Spiny_dogfish",
    "Winter_flounder",
    "Winter_skate",
    "Yellowtail_flounder",
    "Piscivores",
    "Benthivores",
    "Planktivores",
    "Ecosystem"),
    levels = c(
      "Atlantic_cod",
      "Atlantic_herring",
      "Atlantic_mackerel",
      "Goosefish",
      "Haddock",
      "Silver_hake",
      "Spiny_dogfish",
      "Winter_flounder",
      "Winter_skate",
      "Yellowtail_flounder",
      "Piscivores",
      "Benthivores",
      "Planktivores",
      "Ecosystem")))
  
  perfmetrics <- NULL
  perfmetrics$metrics <- metrics
  perfmetrics$median_metrics <- median_metrics
  perfmetrics$sp_timeseries <- mse_results$sp_results %>% 
    select(rep, year, species, advice, bbmsy, ffmsy, biomass, catch, Fyr) %>% 
    left_join(sp_names) %>% 
    I()
  perfmetrics$fleet_catch <- mse_results$fleet_catch
    
  return(perfmetrics)

} #end get_perfmetrics function


# settings$assessType = "stock complex"
# results <- readRDS("~/research/groundfish-MSE/results_2023-06-11-13-20-09/sim/mpres_stock_complex.rds")
# complexes <- tibble(isp = 1:10,
#                     complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2))
# my_metrics <- get_perfmetrics(results, complexes, settings)


calc_metrics <- function(results, yrs = 1:10) {
  #results = mse_results
  #yrs = 43:48
  #yrs = 46:48
 
  cat_yield <- mse_results$sp_results %>% 
    dplyr::filter(year %in% yrs) %>% 
    group_by(rep, species, year) %>% 
    summarize(
      cat_yield = sum(catch, na.rm =TRUE),
      near_btarg = sum(bbmsy > 0.75 & bbmsy < 1.25),
              .groups = "drop") %>% 
    group_by(rep, species) %>% 
    arrange(year) %>% 
    summarize(iav_catch = sqrt(sum(diff(cat_yield)^2)/(n()-1))/(sum(cat_yield)/n()),
              cat_yield = median(cat_yield,na.rm = TRUE), 
              near_btarg = sum(near_btarg)/n(),
              .groups = "drop") %>% 
    I()
    cat_yield$near_btarg[cat_yield$species %in% 1:10] <- NA 
  #cat_yield 
  fleet_yield <- mse_results$fleet_catch %>% 
    dplyr::filter(year %in% yrs) %>% 
    group_by(rep, fleet, year) %>% 
    summarize(fleet_yield = sum(catch, na.rm =TRUE),.groups = "drop") %>% 
    group_by(rep, fleet) %>% 
    arrange(year) %>% 
    summarize(iav_fl_catch = sqrt(sum(diff(fleet_yield)^2)/(n()-1))/(sum(fleet_yield)/n()),
              fleet_yield = median(fleet_yield,na.rm = TRUE), .groups = "drop") %>% 
    I()
  #fleet_yield
  prop_below <- mse_results$sp_results %>% 
    dplyr::filter(year %in% yrs,
                  species %in% 1:10) %>% 
    group_by(rep, year) %>% 
    summarize(prop_below_lim = ifelse(settings$assessType == "stock complex",
                                      mean(bfloor<1),
                                      mean(bbmsy<0.5)),
              .groups = "drop") %>%
    group_by(rep) %>% 
    summarize(prop_below_lim = sum(prop_below_lim)/n(), .groups = "drop") %>% 
    I()
  #prop_below
  prop_overfishing <- mse_results$sp_results %>% 
    dplyr::filter(year %in% yrs) %>% 
    group_by(rep, species) %>% 
    summarize(prop_fabove_lim = mean(ffmsy>1, na.rm=TRUE),
              .groups = "drop") %>%
    drop_na() %>%  
    I()
  #prop_overfishing
  eco_above_bmsy <- mse_results$sp_results %>% 
    dplyr::filter(year %in% yrs,
                  species == 14) %>% 
    group_by(rep) %>% 
    summarize(eco_above_bmsy = mean(bbmsy>=1, na.rm = TRUE),
              .groups = "drop") %>% 
    I()
  #eco_above_bmsy
  
  #foregone yield
  foregone <- mse_results$sp_results %>% 
    dplyr::filter(year %in% yrs,
                  !is.na(advice)) %>% 
    mutate(diff_cat = advice - catch) %>% 
    group_by(rep, year) %>% 
    summarize(foregone_yield = sum(diff_cat, na.rm = TRUE),
              .groups = "drop") %>%
    group_by(rep) %>% 
    summarize(foregone_yield = median(foregone_yield, na.rm = TRUE),
              .groups = "drop") %>% 
    I()
  #foregone
    
  f_reduced <- mse_results$sp_results %>% 
    dplyr::filter(year %in% yrs,
                  species %in% 1:10) %>% 
    select(rep, species, year, Fyr, bfloor) %>% 
    group_by(rep, species) %>% 
    #arrange(year) %>% 
    mutate(F_reduced = c(diff(Fyr),NA)) %>% 
    ungroup() %>%
    mutate(correct_Fadjust = ifelse(bfloor<1, 1, NA),
           correct_Fadjust = ifelse(F_reduced < 0, correct_Fadjust*1, 0*correct_Fadjust)) %>% 
    group_by(rep) %>% 
    summarize(f_reduced = mean(correct_Fadjust,na.rm=TRUE)) %>% 
    #arrange(rep, species) %>% 
    I()

  sp_names <- tibble(species = 1:14, species_name=factor(c(
    "Atlantic_cod",
    "Atlantic_herring",
    "Atlantic_mackerel",
    "Goosefish",
    "Haddock",
    "Silver_hake",
    "Spiny_dogfish",
    "Winter_flounder",
    "Winter_skate",
    "Yellowtail_flounder",
    "Piscivores",
    "Benthivores",
    "Planktivores",
    "Ecosystem"),
    levels = c(
      "Atlantic_cod",
      "Atlantic_herring",
      "Atlantic_mackerel",
      "Goosefish",
      "Haddock",
      "Silver_hake",
      "Spiny_dogfish",
      "Winter_flounder",
      "Winter_skate",
      "Yellowtail_flounder",
      "Piscivores",
      "Benthivores",
      "Planktivores",
      "Ecosystem")))
  
    
  metrics1 <- f_reduced %>% 
    left_join(foregone) %>% 
    left_join(eco_above_bmsy) %>% 
    left_join(prop_below) %>% 
    pivot_longer(cols = -1, names_to = "metric") %>% 
    I()
  #metrics1
  
  metrics2 <- fleet_yield %>% 
    pivot_longer(cols = -(1:2), names_to = "metric") %>% 
    mutate(metric = paste(metric, fleet, sep="_")) %>% 
    select(-fleet) %>% 
    I()
  
  mtemp <- prop_overfishing %>% 
    pivot_longer(cols = -(1:2), names_to = "metric")
  metrics3 <- cat_yield %>% 
    pivot_longer(cols = -(1:2), names_to = "metric") %>% 
    bind_rows(mtemp) %>% 
    left_join(sp_names) %>% 
    mutate(metric = paste(metric, species_name, sep="_")) %>% 
    select(-species, -species_name) %>% 
    I()
  metrics3
  
  results <- NULL
  results$metrics <- bind_rows(metrics1, metrics2, metrics3)
  #results$cat_yield <- cat_yield
  #results$fleet_yield <- fleet_yield
  
  return(results)
  
} #end function calc_metrics
  
  
get_mse_results <- function(results, complexes, settings = list(assessType = "stock complex")) {
  #get tables of time series by simulation
  om_bio <- map_dfr(results$biomass,I,.id = "rep") %>% 
    janitor::clean_names() %>% 
    left_join(complexes, by = c("species" = "isp")) %>%
    I()
  #head(om_bio)
  catch <- map_dfr(results$catch,I,.id = "rep") %>% 
    janitor::clean_names() %>% 
    I()
  sp_catch <- catch %>% 
    #select(-cv) %>% 
    group_by(year, species, rep) %>% 
    summarize(catch = sum(predcatch), .groups = "drop") %>% 
    left_join(complexes, by = c("species" = "isp")) %>%
    I()
  fleet_catch <- catch %>% 
    group_by(year, fleet, rep) %>% 
    summarize(catch = sum(predcatch), .groups = "drop") %>% 
    I()
  #head(sp_catch)
  #head(fleet_catch)
  om_results <- om_bio %>% 
    left_join(sp_catch)
  
  complex_results <- om_results %>% 
    select(-species) %>% 
    group_by(rep, year, complex) %>% 
    summarize_all(sum) %>% 
    mutate(species = complex + 10) %>% 
    #select(-complex)
    I()
  #complex_results
  eco_results <- om_results %>% 
    select(-species, -complex) %>% 
    group_by(rep, year) %>% 
    summarize_all(sum) %>% 
    mutate(species = 14)  
  #eco_results  
  
  #join time series for complexes and ecosystem to species time series
  om_results <- om_results %>% 
    bind_rows(complex_results) %>% 
    bind_rows(eco_results) %>% 
    I()
  #om_results
  
  #pull out mp results
  mp_results <- map_dfr(results$mp_results,~map_dfr(., "refs",.id="year"),.id = "rep") %>% 
    mutate(year = as.numeric(year) + 42) %>% 
    rename(species = isp)
  mp_advice <- map_dfr(results$mp_results,~map_dfr(., "out_table",.id="year"),.id = "rep") %>% 
    mutate(year = as.numeric(year) + 42)
  if (settings$assessType == "stock complex")
    mp_advice <- mutate(mp_advice, species = as.numeric(complex) + 10)
  if (settings$assessType != "stock complex")
    mp_advice <- mutate(mp_advice, species = as.numeric(isp))
  #join the mp results to the om time series
  sp_results <- mp_advice %>% 
    select(rep, year, species, advice) %>% 
    right_join(mp_results) %>% 
    right_join(om_results)
  
  #F
  Fyrspecies <- map_dfr(results$Fyrspecies,I,.id="rep")
  names(Fyrspecies)[4:ncol(Fyrspecies)] <-seq(1,ncol(Fyrspecies)-3)
  Fyrspecies <- reshape2::melt(Fyrspecies,id=1:3)
  names(Fyrspecies)[4:ncol(Fyrspecies)] <- c("year","Fyr")
  Fyrspecies$year <- as.double(Fyrspecies$year)
  Fyr <- Fyrspecies %>% 
    #select(-fleet) %>%
    left_join(catch) %>% 
    select(rep, species, fleet, year, Fyr, predcatch) %>% 
    #dplyr::filter(rep ==1 , year == 1) %>% #, species == 2) %>% 
    group_by(rep, species, year) %>%
    summarize(Fyr = sum(Fyr*predcatch/sum(predcatch), na.rm = TRUE),
              .groups = "drop")
  
  sp_results <- sp_results %>% 
    left_join(Fyr)

  
  ###### finishes getting tables of time series output
  mse_results <- NULL
  mse_results$sp_results <- sp_results
  mse_results$fleet_catch <- fleet_catch
  
  return(mse_results)  
} #ends get_mse_results() function  
  
  
library(tidyverse)
library(ggdist)
library(reshape2)

#mp_results <- readRDS("~/research/groundfish-MSE/results_2023-05-19-16-39-54/sim/mpres2023-05-19_170353_6465.rds")
# mp_results <- readRDS("~/research/groundfish-MSE/functions/hydra/plots/sc-res-20230519.rds")
mp_results <- `mpresstock complex`
feeding_complexes <- tibble(isp = 1:10,
                            complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2))
gear_complexes <- tibble(isp = 1:10,
                         complex = c(1, 3, 3, 1, 1, 3, 1, 2, 1, 2))

Fyrspecies <- map_dfr(results$Fyrspecies,I,.id="rep")
names(Fyrspecies)[4:ncol(Fyrspecies)] <-seq(1,ncol(Fyrspecies)-3)
Fyrspecies <- reshape2::melt(Fyrspecies,id=1:3)
names(Fyrspecies)[4:ncol(Fyrspecies)] <- c("year","Fyr")
Fyrspecies$year <- as.double(Fyrspecies$year)

biomass <- map_dfr(mp_results$biomass,I,.id = "rep") %>% 
  janitor::clean_names()

catch <- map_dfr(mp_results$catch,I,.id = "rep") %>% 
  #select(-cv) %>% 
  group_by(year, species, rep) %>% 
  summarize(catch = sum(predcatch), .groups = "drop")

results1 <- biomass %>% 
  left_join(catch) %>% 
  left_join(Fyrspecies) %>%
  left_join(feeding_complexes, by = c("species" = "isp")) %>% 
  mutate(mp = "stock complex MA") 

#ss_results <- readRDS("~/research/groundfish-MSE/results_2023-05-19-16-08-04/sim/mpres2023-05-19_163236_5129.rds")
#ss_results <- readRDS("~/research/groundfish-MSE/functions/hydra/plots/ss-2023-05-19.rds")
# ss_results <- readRDS("~/research/groundfish-MSE/functions/hydra/plots/ss-2023-05-20.rds")
# ss_results <- readRDS("/results_2023-06-08-11-50-09/sim/mpressinglespecies.rds")
ss_results <- `mpressinglespecies`

Fyrspecies <- map_dfr(results$Fyrspecies,I,.id="rep")
names(Fyrspecies)[4:ncol(Fyrspecies)] <-seq(1,ncol(Fyrspecies)-3)
Fyrspecies <- reshape2::melt(Fyrspecies,id=1:3)
names(Fyrspecies)[4:ncol(Fyrspecies)] <- c("year","Fyr")
Fyrspecies$year <- as.double(Fyrspecies$year)

biomass <- map_dfr(ss_results$biomass,I,.id = "rep") %>% 
  janitor::clean_names()

catch <- map_dfr(ss_results$catch,I,.id = "rep") %>% 
  #select(-cv) %>% 
  group_by(year, species, rep) %>% 
  summarize(catch = sum(predcatch), .groups = "drop")

results2 <- biomass %>% 
  left_join(catch) %>% 
  left_join(Fyrspecies) %>%
  left_join(feeding_complexes, by = c("species" = "isp")) %>% 
  mutate(mp = "single species MA")

results <- results1 %>% 
  bind_rows(results2)

complex_res <- results %>% 
  select(-species) %>% 
  group_by(rep, year, complex, mp) %>% 
  summarize_all(sum) %>% 
  mutate(species = complex + 10) %>% 
  select(-complex)

eco_res <- results %>% 
  select(-species, -complex) %>% 
  group_by(rep, year, mp) %>% 
  summarize_all(sum) %>% 
  mutate(species = 14)

results <- results %>% 
  bind_rows(complex_res) %>%
  bind_rows(eco_res) %>% 
  pivot_longer(cols = c("biomass","catch","Fyr"), names_to = "type")

sp_names <- tibble(species = 1:14, species_name=factor(c(
  "Atlantic_cod",
  "Atlantic_herring",
  "Atlantic_mackerel",
  "Goosefish",
  "Haddock",
  "Silver_hake",
  "Spiny_dogfish",
  "Winter_flounder",
  "Winter_skate",
  "Yellowtail_flounder",
  "Piscivores",
  "Benthivores",
  "Planktivores",
  "Ecosystem"),
  levels = c(
    "Atlantic_cod",
    "Atlantic_herring",
    "Atlantic_mackerel",
    "Goosefish",
    "Haddock",
    "Silver_hake",
    "Spiny_dogfish",
    "Winter_flounder",
    "Winter_skate",
    "Yellowtail_flounder",
    "Piscivores",
    "Benthivores",
    "Planktivores",
    "Ecosystem")))

perf_metrics <- results %>% 
  left_join(sp_names)

bmsy <- perf_metrics %>% 
  dplyr::filter(year <= 40, type == "biomass") %>% 
  group_by(species, rep, mp) %>% 
  summarize(bmsy = mean(value, na.rm=TRUE)) %>% 
  ungroup()

perf_metrics <- perf_metrics %>% 
  left_join(bmsy) %>% 
  mutate(bbmsy = ifelse(type == "biomass", value / bmsy, NA))

p1 <- perf_metrics %>% 
  dplyr::filter(type == "biomass",
                year > 40) %>% 
  ggplot() +
  aes(x = year, y = value, fill = mp, col = mp) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "biomass") +
  facet_wrap(~species_name, scales = "free_y") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave("output/biomass.png", p1)

p2 <- perf_metrics %>% 
  dplyr::filter(type == "biomass",
                year > 40) %>% 
  ggplot() +
  aes(x = year, y = bbmsy, fill = mp, col = mp) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "B / HCR_BMSY") +
  geom_hline(yintercept = 1, lty=2) +
  facet_wrap(~species_name, scales = "free_y") +
  theme(#axis.text.y = element_blank(),
    legend.position = "bottom")
ggsave("output/bbmsy.png", p2)

p3 <- perf_metrics %>% 
  dplyr::filter(type == "catch",
                year > 40) %>% 
  ggplot() +
  aes(x = year, y = value, fill = mp, col = mp) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "catch") +
  facet_wrap(~species_name, scales = "free_y") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave("output/catch.png", p3)

summary_metrics <- perf_metrics %>% 
  dplyr::filter(year >= 40) %>% 
  group_by(type, rep, mp, species_name) %>% 
  summarize(short = mean(value[year<52], na.rm = TRUE),
            long = mean(value[year>62], na.rm = TRUE,)) %>% 
  pivot_longer(cols = c("short","long"),names_to = "time")

p4 <- summary_metrics %>% 
  dplyr::filter(type == "biomass") %>% 
  ggplot() +
  aes(x = time, y = value, fill = mp) +
  geom_boxplot() +
  ylim(0,NA) +
  facet_wrap(~species_name, scales = "free_y") +
  labs(x = "time horizon", y = "biomass") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave("output/bio_boxplots.png", p4)
# summary_metrics %>% 
#   dplyr::filter(type == "biomass") %>% 
#   ggplot() +
#   aes(x = time, y = bbmsy, fill = mp) +
#   geom_boxplot() +
#   ylim(0,NA) +
#   geom_hline(yintercept = 1, lty=2) +
#   facet_wrap(~species_name, scales = "free_y") +
#   labs(x = "time horizon", y = "B / HCR BMSY") +
#   theme(#axis.text.y = element_blank(),
#         legend.position = "bottom")

p5 <- summary_metrics %>% 
  dplyr::filter(type == "catch") %>% 
  ggplot() +
  aes(x = time, y = value, fill = mp) +
  geom_boxplot() +
  ylim(0,NA) +
  facet_wrap(~species_name, scales = "free_y") +
  labs(x = "time horizon", y = "catch") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave("output/cat_boxplots.png", p5)

p6 <- perf_metrics %>% 
  dplyr::filter(type == "Fyr",
                year > 40) %>% 
  ggplot() +
  aes(x = year, y = value, fill = mp, col = mp) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "Fyr") +
  facet_wrap(~species_name, scales = "free_y") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave("output/Fyr.png", p6)