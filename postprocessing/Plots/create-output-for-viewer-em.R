library(tidyverse)
library(ggdist)
library(fmsb)
#If you run into problems with the select() function you may need to remove the MASS package
# detach("package:MASS", unload = TRUE)

source("postprocessing/Plots/radar_chart.R")
source("postprocessing/Plots/get_perfmetrics.R")

#How to save the file within "output"
# foldername <- Sys.time() 
# foldername <- Sys.data()
foldername <- "Management Scenarios"
if(!dir.exists(paste0("output/",foldername))) dir.create(paste0("output/",foldername))

# settings <- NULL
# settings$assessType = "stock complex"
# settings2 <- NULL
# settings2$assessType = "stock complex"
# settings3 <- NULL
# settings3$assessType = "stock complex"
# settings4 <- NULL
# settings4$assessType = "stock complex"
# settings5 <- NULL
# settings5$assessType = "stock complex"

settings <- NULL
settings$assessType = "single species"
settings2 <- NULL
settings2$assessType = "single species"
settings3 <- NULL
settings3$assessType = "stock complex"
settings4 <- NULL
settings4$assessType = "stock complex"
settings5 <- NULL
settings5$assessType = "stock complex"
settings6 <- NULL
settings6$assessType = "stock complex"
#results <- readRDS("~/research/groundfish-MSE/results_2023-06-11-13-20-09/sim/mpres_stock_complex.rds")
complexes <- tibble(isp = 1:10,
                    complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2))
#my_metrics <- get_perfmetrics(results, complexes, settings)

### create a tibble that is the main table with the labels for the scenarios, mps, etc., 
# and the corresponding complexes & settings, & files with the results from the MSE
#basically this is a main table that can be used to create the results tables for plots/tables/shiny viewer.
res_setup <- tibble(
settings = list(settings, settings2, settings3, settings4, settings5,settings6),
complexes = list(complexes, complexes, complexes, complexes, complexes,complexes),
# mp = c("stock complex", "stock complex", "stock complex", "stock complex", "stock complex"),
mp = c("single species", "single species", "stock complex", "stock complex", "stock complex","stock complex"),
scenario = c("SS Static", "SS Dynamic", "Feeding Complex Static", "Feeding Complex Dynamic", "Gear Complex Static", "Gear Complex Dynamic"),
# files = c("results_2023-07-21-13-09-41/sim/mpres_single_species.rds",
#                   #"~/research/groundfish-MSE/results_2023-06-11-13-20-09/sim/mpres_stock_complex.rds",  # 2 replicates, stock complex, lowB
#           "results_2023-07-06-16-30-09/sim/mpres_stock_complex.rds"), # 10 replicates, stock complex, lowB
# Files on EML personal computer:
files = c("finalrdsfiles/001.rds",
          "finalrdsfiles/002.rds",
          "finalrdsfiles/003.rds",
          "finalrdsfiles/004.rds",
          "finalrdsfiles/021.rds",
          "finalrdsfiles/022.rds")
)



foragebiomass <- data.frame(mp=c(),scenario=c(),rep=c(),year=c(),biomass=c())
for(i in 1:length(res_setup$files))
{
  for(j in 1:length(readRDS(res_setup$files[i])$foragebiomass))
  {
    for(k in 1:nrow(readRDS(res_setup$files[i])$foragebiomass[[j]]))
    {
      foragebiomassnew <- data.frame(mp=res_setup$mp[i],scenario=res_setup$scenario[i],rep=j,year=k,biomass=readRDS(res_setup$files[i])$foragebiomass[[j]][k,2])
      foragebiomass <- rbind(foragebiomass,foragebiomassnew)
    }
  }
}
foragebiomass <- distinct(foragebiomass)

res_metrics <- res_setup %>% 
  mutate(results = map(files, readRDS))
res_metrics <- res_metrics %>% 
  mutate(metric_bundle = pmap(list(results = res_metrics$results,
                                   complexes = res_setup$complexes,
                                   settings = res_setup$settings),
                              #list(results, complexes, settings),
                              get_perfmetrics)) %>% 
  dplyr::select(mp, scenario, metric_bundle) %>% 
  # mutate(metrics = map(metric_bundle, "metrics"),
  #        median_metrics = map(metric_bundle, "median_metrics"),
  #        sp_timeseries = map(metric_bundle, "sp_timeseries"),
  #        fleet_catch = map(metric_bundle, "fleet_catch"))
  I()
saveRDS(res_metrics, file = paste0("output/",foldername,"/res_metrics.rds"))
#res_metrics


########## plotting #############

res_metrics <- readRDS(paste0("output/",foldername,"/res_metrics.rds")) %>% 
  mutate(metrics = map(metric_bundle, "metrics"),
         median_metrics = map(metric_bundle, "median_metrics"),
         sp_timeseries = map(metric_bundle, "sp_timeseries"),
         fleet_catch = map(metric_bundle, "fleet_catch"))

# metrics (by replicate)
metrics <- res_metrics %>% 
  dplyr::select(mp, scenario, metrics) %>% 
  unnest(metrics)
#metrics

# median_metrics (summarized over replicates)
median_metrics <- res_metrics %>% 
  dplyr::select(mp, scenario, median_metrics) %>% 
  unnest(median_metrics)
#median_metrics

# metrics (by replicate)
sp_timeseries <- res_metrics %>% 
  dplyr::select(mp, scenario, sp_timeseries) %>% 
  unnest(sp_timeseries) %>% 
  dplyr::select(-species) %>% 
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

labels <- c("cat_yield_Ecosystem"="Ecosystem yield",
            "fleet_yield_1"="Fleet 1 Yield",
            "fleet_yield_2"="Fleet 2 Yield",
            "iav_catch_Ecosystem"="Interannual variability in ecosystem catch",
            "prop_below_lim"="Proportion below limit",
            "eco_above_bmsy"= "Ecosystem above Bmsy",
            "near_btarg_Piscivores"="Piscivores near Btarget",
            "near_btarg_Benthivores"="Benthivores near Btarget",
            "near_btarg_Planktivores"="Planktivore near Btarget",
            "f_reduced"="F reduced",
            "foregone_yield"="Underutilized quota")

metrics <- metrics %>%
  mutate( scenario=factor(scenario,levels=c("SS Static", "SS Dynamic", "Feeding Complex Static", "Feeding Complex Dynamic", "Gear Complex Static")) ) %>%
  mutate(value= ifelse(is.na(value),NA,value))

# box plots for key metrics
bxp1 <- metrics %>% 
        dplyr::filter(metric %in% key_metrics,
         time == "long") %>% 
  ggplot() +
  aes(x = scenario, y = value, fill = scenario) +
  geom_boxplot(outlier.shape=NA) +
  # scale_fill_brewer(type = "qual", palette = 2) +
  scale_fill_manual(values=c("#f4f1de","#e07a5f", "#3d405b","#81b29a","#f2cc8f"))+
  ylim(0,NA) +
  # facet_wrap(~metric, scales = "free_y", drop=F) +
  facet_wrap(~metric, scales = "free_y", drop=F, labeller=as_labeller(labels)) +
  theme_bw() +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank() 
  )+
  # theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))+
  # theme(axis.text.x = element_text(angle = 45, vjust=0.25))+
  labs(x = "management alternative", y = "value",
       title = "key metrics over the long-term") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
bxp1
ggsave(paste0("output/",foldername,"/metric_long_boxplots.png"), bxp1, width=12, height=8)

# box plots for key metrics, short-term
bxp2 <- metrics %>% 
  dplyr::filter(metric %in% key_metrics,
         time == "short") %>% 
  ggplot() +
  aes(x = scenario, y = value, fill = scenario) +
  geom_boxplot(outlier.shape=NA) +
  # scale_fill_brewer(type = "qual", palette = 2) +
  scale_fill_manual(values=c("#f4f1de","#e07a5f", "#3d405b","#81b29a","#f2cc8f"))+
  ylim(0,NA) +
  # facet_wrap(~metric, scales = "free_y", drop=F) +
  facet_wrap(~metric, scales = "free_y", drop=F, labeller=as_labeller(labels)) +
  theme_bw() +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank() 
  )+
  # theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))+
  # theme(axis.text.x = element_text(angle = 45, vjust=0.25))+
  labs(x = "management alternative", y = "value",
       title = "key metrics over the short-term") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
bxp2
ggsave(paste0("output/",foldername,"/metric_short_boxplots.png"), bxp2, width=12, height=8)


# box plots for key metrics, single OM, both time horizons
# bxp3 <- metrics %>% 
#   dplyr::filter(metric %in% key_metrics) %>% 
#   mutate(time = factor(time, levels=c("short","long"))) %>% 
#   ggplot() +
#   aes(x = scenario, y = value, fill = time) +
#   geom_boxplot(outlier.shape=NA) +
#   scale_fill_brewer(type = "qual", palette = 2) +
#   ylim(0,NA) +
#   facet_wrap(~metric, scales = "free_y", drop=F) +
#   theme_bw() +
#   labs(x = "management alternative", y = "value",
#        title = "key metrics for the lowB operating model scenario") +
#   theme(axis.text.y = element_blank(),
#         legend.position = "bottom")
# bxp3
# ggsave("output/2023-06-11/metric_long_boxplots.png", bxp3, width=12, height=8)


# dot plots for medians of key metrics - long-term
dotp1 <- median_metrics %>% 
  dplyr::filter(metric %in% key_metrics,
         time == "long") %>% 
  ggplot() +
  aes(x = scenario, y = value, col = scenario) +
  geom_point() +
  geom_line(aes(x = mp, y = value, group = scenario), col = "gray") +
  geom_point() + 
  scale_color_brewer(type = "qual", palette = 2) +
  # facet_wrap(~metric, scale = "free_y", drop = F) +
  facet_wrap(~metric, scales = "free_y", drop=F, labeller=as_labeller(labels)) +
  ylim(0,NA) +
  ylab("value") +
  xlab("management alternative") +
  theme_bw() +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank() 
  )+
  # theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))+
  # theme(axis.text.x = element_text(angle = 45, vjust=0.25))+
  theme(legend.position = "bottom",
        axis.text.x = element_blank()) +
  labs(fill = "",
       col = "",
       title = "key metrics in the long-term over all operating model scenarios") +
  guides(col = guide_legend(nrow = 2),
         shape = guide_legend(nrow = 2))
dotp1  
ggsave(paste0("output/",foldername,"/metric_long_dotplots.png"), dotp1, width=12, height=8)

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
  # facet_wrap(~metric, scale = "free_y", drop = F) +
  facet_wrap(~metric, scales = "free_y", drop=F, labeller=as_labeller(labels)) +
  ylim(0,NA) +
  ylab("value") +
  xlab("management alternative") +
  theme_bw() +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank() 
  )+
  # theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))+
  # theme(axis.text.x = element_text(angle = 45, vjust=0.25))+
  theme(legend.position = "bottom",
        axis.text.x = element_blank()) +
  labs(fill = "",
       col = "",
       title = "key metrics in the long-term over all operating model scenarios") +
  guides(col = guide_legend(nrow = 2),
         shape = guide_legend(nrow = 2))
dotp1  
ggsave(paste0("output/",foldername,"/metric_short_dotplots.png"), dotp2, width=12, height=8)

sp_timeseries <- sp_timeseries %>%
  mutate( scenario=factor(scenario,levels=c("SS Static", "SS Dynamic", "Feeding Complex Static", "Feeding Complex Dynamic", "Gear Complex Static","Gear Complex Dynamic")) )

# time series of OM biomass
# make a sp_timeseries specific to biomass to include foragebiomass
sp_timeseries_bio <- sp_timeseries
sp_timeseries_bio[(nrow(sp_timeseries)+1):(nrow(sp_timeseries)+nrow(foragebiomass)),]<-NA
sp_timeseries_bio[(nrow(sp_timeseries)+1):(nrow(sp_timeseries)+nrow(foragebiomass)),"mp"]<-foragebiomass$mp
sp_timeseries_bio[(nrow(sp_timeseries)+1):(nrow(sp_timeseries)+nrow(foragebiomass)),"scenario"]<-foragebiomass$scenario
sp_timeseries_bio[(nrow(sp_timeseries)+1):(nrow(sp_timeseries)+nrow(foragebiomass)),"rep"]<-as.character(as.numeric(foragebiomass$rep))
sp_timeseries_bio[(nrow(sp_timeseries)+1):(nrow(sp_timeseries)+nrow(foragebiomass)),"year"]<-foragebiomass$year
sp_timeseries_bio[(nrow(sp_timeseries)+1):(nrow(sp_timeseries)+nrow(foragebiomass)),"biomass"]<-foragebiomass$biomass
sp_timeseries_bio$species_name <- as.character(sp_timeseries_bio$species_name)
sp_timeseries_bio[(nrow(sp_timeseries)+1):(nrow(sp_timeseries)+nrow(foragebiomass)),"species_name"]<-rep(as.factor("Forage"),nrow(foragebiomass))
sp_timeseries_bio$species_name <- factor(sp_timeseries_bio$species_name,levels = c(
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
  "Ecosystem",
  "Forage"))

om_plot1 <- sp_timeseries_bio %>% 
  dplyr::filter(year > 40) %>% 
  ggplot() +
  aes(x = year, y = biomass, fill = scenario, col = scenario) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "biomass",
       title = "true biomass for the lowB operating model scenario") +
  facet_wrap(~species_name, scales = "free_y") +
  # facet_wrap(~metric, scales = "free_y", drop=F, labeller=as_labeller(labels)) +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave(paste0("output/",foldername,"/biomass_timeseries.png"), om_plot1, width=12, height=8)

# time series of catch
om_plot2 <- sp_timeseries %>% 
  dplyr::filter(year > 40) %>% 
  ggplot() +
  aes(x = year, y = catch, fill = scenario, col = scenario) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "catch",
       title = "realized catch for the lowB operating model scenario") +
  facet_wrap(~species_name, scales = "free_y") +
  # facet_wrap(~metric, scales = "free_y", drop=F, labeller=as_labeller(labels)) +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave(paste0("output/",foldername,"/catch_timeseries.png"), om_plot2, width=12, height=8)

# time series of b/bmsy
om_plot3 <- sp_timeseries %>% 
  dplyr::filter(year > 40) %>% 
  ggplot() +
  aes(x = year, y = bbmsy, fill = scenario, col = scenario) +
  stat_lineribbon(
    #show.legend = FALSE,
    alpha = 0.35) +
  ylim(0,NA) +
  labs(y = "B / HCR_BMSY",
       title = "B/BMSY for the lowB operating model scenario") +
  geom_hline(yintercept = 1, lty=2) +
  facet_wrap(~species_name, scales = "free_y") +
  # facet_wrap(~metric, scales = "free_y", drop=F, labeller=as_labeller(labels)) +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")
ggsave(paste0("output/",foldername,"/bbmsy_timeseries.png"), om_plot3, width=12, height=8)





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
png(filename =paste0("output/",foldername,"/radar_plot.png"),)
radar_p1 <- median_metrics %>% 
  dplyr::filter(metric %in% key_metrics,
         time == "long") %>% 
  mutate(value = ifelse(metric=="prop_below_lim",1-value,value),
         metric = ifelse(metric=="prop_below_lim","prop_above_lim",metric),
         scenario = factor(scenario),
         mp = scenario
         #om = fct_recode(om, "Base" = "1","MRIP Bias" = "2","Shift" = "3"),
         ) %>% 
  mutate(value= ifelse(is.na(value),1,value)) %>%
  mutate(value= ifelse(metric=="foregone_yield",1/value,value)) %>%
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
  