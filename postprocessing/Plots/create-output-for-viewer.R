library(tidyverse)
library(ggdist)
library(fmsb)

source("postprocessing/Plots/radar_chart.R")
source("postprocessing/Plots/get_perfmetrics.R")

settings <- NULL
settings$assessType = "stock complex"
settings2 <- settings
settings2$assessType = "single species"
#results <- readRDS("~/research/groundfish-MSE/results_2023-06-11-13-20-09/sim/mpres_stock_complex.rds")
complexes <- tibble(isp = 1:10,
                    complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2))
#my_metrics <- get_perfmetrics(results, complexes, settings)

### create a tibble that is the main table with the labels for the scenarios, mps, etc., 
# and the corresponding complexes & settings, & files with the results from the MSE
#basically this is a main table that can be used to create the results tables for plots/tables/shiny viewer.
res_setup <- tibble(
settings = list(settings2, settings),
complexes = list(complexes, complexes),
mp = c("single species", "stock complex"),
scenario = c("lowB","lowB"),
files = c("results_2023-06-14-18-21-41/sim/mpres_single_species.rds",
                  #"~/research/groundfish-MSE/results_2023-06-11-13-20-09/sim/mpres_stock_complex.rds",  # 2 replicates, stock complex, lowB
          "results_2023-06-14-16-35-38/sim/mpres_stock_complex.rds"), # 10 replicates, stock complex, lowB
)


res_metrics <- res_setup %>% 
  mutate(results = map(files, readRDS))
res_metrics <- res_metrics %>% 
  mutate(metric_bundle = pmap(list(results = res_metrics$results,
                                   complexes = res_setup$complexes,
                                   settings = res_setup$settings),
                              #list(results, complexes, settings),
                              get_perfmetrics)) %>% 
  select(mp, scenario, metric_bundle) %>% 
  # mutate(metrics = map(metric_bundle, "metrics"),
  #        median_metrics = map(metric_bundle, "median_metrics"),
  #        sp_timeseries = map(metric_bundle, "sp_timeseries"),
  #        fleet_catch = map(metric_bundle, "fleet_catch"))
  I()
saveRDS(res_metrics, file = "output/res_metrics.rds")
#res_metrics


########## plotting #############

res_metrics <- readRDS("output/res_metrics.rds") %>% 
  mutate(metrics = map(metric_bundle, "metrics"),
         median_metrics = map(metric_bundle, "median_metrics"),
         sp_timeseries = map(metric_bundle, "sp_timeseries"),
         fleet_catch = map(metric_bundle, "fleet_catch"))

# metrics (by replicate)
metrics <- res_metrics %>% 
  select(mp, scenario, metrics) %>% 
  unnest(metrics)
#metrics

# median_metrics (summarized over replicates)
median_metrics <- res_metrics %>% 
  select(mp, scenario, median_metrics) %>% 
  unnest(median_metrics)
#median_metrics

# metrics (by replicate)
sp_timeseries <- res_metrics %>% 
  select(mp, scenario, sp_timeseries) %>% 
  unnest(sp_timeseries) %>% 
  select(-species) %>% 
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
  "Ecosystem"), ordered = TRUE))

key_metrics <- c("cat_yield_Ecosystem",
                 "fleet_yield_1",
                 "fleet_yield_2",
                 "iav_catch_Ecosystem",
                 "prop_below_lim",
                 "eco_above_bmsy",
                 "near_btarg_Piscivores",
                 "near_btarg_Benthivores",
                 "near_btarg_Planktivores",
                 "f_reduced",
                 "foregone_yield")


# box plots for key metrics
bxp1 <- metrics %>% 
        dplyr::filter(metric %in% key_metrics,
         time == "long") %>% 
  ggplot() +
  aes(x = mp, y = value, fill = scenario) +
  geom_boxplot(outlier.shape=NA) +
  scale_fill_brewer(type = "qual", palette = 2) +
  ylim(0,NA) +
  facet_wrap(~metric, scales = "free_y", drop=F) +
  theme_bw() +
  labs(x = "management alternative", y = "value",
       title = "key metrics over the long-term") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
bxp1
ggsave("output/2023-06-11/metric_long_boxplots.png", bxp1, width=12, height=8)

# box plots for key metrics, short-term
bxp2 <- metrics %>% 
  dplyr::filter(metric %in% key_metrics,
         time == "short") %>% 
  ggplot() +
  aes(x = mp, y = value, fill = scenario) +
  geom_boxplot(outlier.shape=NA) +
  scale_fill_brewer(type = "qual", palette = 2) +
  ylim(0,NA) +
  facet_wrap(~metric, scales = "free_y", drop=F) +
  theme_bw() +
  labs(x = "management alternative", y = "value",
       title = "key metrics over the short-term") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
bxp2
ggsave("output/2023-06-11/metric_short_boxplots.png", bxp2, width=12, height=8)

# box plots for key metrics, single OM, both time horizons
bxp3 <- metrics %>% 
  dplyr::filter(metric %in% key_metrics,
         scenario == "lowB") %>% 
  mutate(time = factor(time, levels=c("short","long"))) %>% 
  ggplot() +
  aes(x = mp, y = value, fill = time) +
  geom_boxplot(outlier.shape=NA) +
  scale_fill_brewer(type = "qual", palette = 2) +
  ylim(0,NA) +
  facet_wrap(~metric, scales = "free_y", drop=F) +
  theme_bw() +
  labs(x = "management alternative", y = "value",
       title = "key metrics for the lowB operating model scenario") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
bxp3
ggsave("output/2023-06-11/metric_long_boxplots.png", bxp3, width=12, height=8)


# dot plots for medians of key metrics - long-term
dotp1 <- median_metrics %>% 
  dplyr::filter(metric %in% key_metrics,
         time == "long") %>% 
  ggplot() +
  aes(x = mp, y = value, col = mp, shape = scenario) +
  geom_point() +
  geom_line(aes(x = mp, y = value, group = scenario), col = "gray") +
  geom_point() + 
  scale_color_brewer(type = "qual", palette = 2) +
  facet_wrap(~metric, scale = "free_y", drop = F) +
  ylim(0,NA) +
  ylab("value") +
  xlab("management alternative") +
  theme_bw() +
  theme(legend.position = "bottom",
        axis.text.x = element_blank()) +
  labs(fill = "",
       col = "",
       title = "key metrics in the long-term over all operating model scenarios") +
  guides(col = guide_legend(nrow = 2),
         shape = guide_legend(nrow = 2))
dotp1  
ggsave("output/2023-06-11/metric_long_dotplots.png", dotp1, width=12, height=8)

# dot plots for medians of key metrics - long-term
dotp2 <- median_metrics %>% 
  dplyr::filter(metric %in% key_metrics,
         time == "short") %>% 
  ggplot() +
  aes(x = mp, y = value, col = mp, shape = scenario) +
  geom_point() +
  geom_line(aes(x = mp, y = value, group = scenario), col = "gray") +
  geom_point() + 
  scale_color_brewer(type = "qual", palette = 2) +
  facet_wrap(~metric, scale = "free_y", drop = F) +
  ylim(0,NA) +
  ylab("value") +
  xlab("management alternative") +
  theme_bw() +
  theme(legend.position = "bottom",
        axis.text.x = element_blank()) +
  labs(fill = "",
       col = "",
       title = "key metrics in the long-term over all operating model scenarios") +
  guides(col = guide_legend(nrow = 2),
         shape = guide_legend(nrow = 2))
dotp1  
ggsave("output/2023-06-11/metric_short_dotplots.png", dotp2, width=12, height=8)


# time series of OM biomass
om_plot1 <- sp_timeseries %>% 
  dplyr::filter(year > 40,
                scenario == "lowB") %>% 
  ggplot() +
  aes(x = year, y = biomass, fill = mp, col = mp) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "biomass",
       title = "true biomass for the lowB operating model scenario") +
  facet_wrap(~species_name, scales = "free_y") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave("output/2023-06-11/biomass_timeseries.png", om_plot1, width=12, height=8)

# time series of catch
om_plot2 <- sp_timeseries %>% 
  dplyr::filter(year > 40,
                scenario == "lowB") %>% 
  ggplot() +
  aes(x = year, y = catch, fill = mp, col = mp) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "catch",
       title = "realized catch for the lowB operating model scenario") +
  facet_wrap(~species_name, scales = "free_y") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave("output/2023-06-11/catch_timeseries.png", om_plot2, width=12, height=8)

# time series of b/bmsy
om_plot3 <- sp_timeseries %>% 
  dplyr::filter(year > 40,
                scenario == "lowB") %>% 
  ggplot() +
  aes(x = year, y = bbmsy, fill = mp, col = mp) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "B / HCR_BMSY",
       title = "B/BMSY for the lowB operating model scenario") +
  geom_hline(yintercept = 1, lty=2) +
  facet_wrap(~species_name, scales = "free_y") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave("output/2023-06-11/bbmsy_timeseries.png", om_plot3, width=12, height=8)

# radar chart of tradeoffs among key metrics for the Base operating model scenario
# radar chart - not sure how to save this to file automagically
key_metrics <- c("cat_yield_Ecosystem",
                 "fleet_yield_1",
                 "fleet_yield_2",
                 "iav_catch_Ecosystem",
                 "prop_below_lim",
                 "eco_above_bmsy",
                 # "near_btarg_Piscivores",
                 # "near_btarg_Benthivores",
                 # "near_btarg_Planktivores",
                 "f_reduced",
                 "foregone_yield")
png(filename ="output/2023-06-11/radar_plot.png")
radar_p1 <- median_metrics %>% 
  dplyr::filter(metric %in% key_metrics,
         time == "long") %>% 
  mutate(value = ifelse(metric=="prop_below_lim",1-value,value),
         metric = ifelse(metric=="prop_below_lim","prop_above_lim",metric),
         scenario = factor(scenario),
         #om = fct_recode(om, "Base" = "1","MRIP Bias" = "2","Shift" = "3"),
         ) %>% 
  #filter(scenario == "lowB") %>% 
  # mutate(mp = fct_recode(mp,
  #                        "status quo" = "MP 1",
  #                        "minsize-1" = "MP 2", 
  #                        "season" = "MP 3", 
  #                        "region" = "MP 4",
  #                        #"c1@14" = "MP 5", 
  #                        "3@17" = "MP 6",
  #                        "1@16-19" = "MP 7",
  #                        "slot" = "MP 8")) %>% 
  #filter(metric %in% c("change_cs", "kept per trip", "kept:released", "not overfished", "not overfishing", "keep_one")) %>% 
  do_small_radar_plot()
  dev.off()
  