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

Fyrspecies <- map_dfr(mp_results$Fyrspecies,I,.id="rep")
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

Fyrspecies <- map_dfr(ss_results$Fyrspecies,I,.id="rep")
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
    "Ecosystem"), ordered = TRUE))

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