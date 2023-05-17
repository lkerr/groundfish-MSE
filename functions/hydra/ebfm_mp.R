## 
## do the (stock complex) management procedure 
##

#######################
#example run with generated data
library(tidyverse)
source("R/mp_functions.R")
# create the list of parameters for the MP
settings <- list(
  showTimeSeries = "No",
  useCeiling = "Yes",
  assessType = "stock complex",
  targetF = 0.75,
  floorB = 1, #0.5,
  floorOption = "min status",
  bramp = 0.9,
  blim = 0.1,
  fmin = 0,
  floorYrs = 1:40)

#set up some dummy data
input <- get_om_pars()
om_long <- run_om(input)
#assess_results <- run_assessments(om_long)
assess_results <- run_pseudo_assessments(om_long)

#call the MP
mp_results <- do_ebfm_mp(settings, assess_results, input)
#remove_rownames() %>%
#ungroup() %>% 
#as_tibble()
mp_results$out_table %>% 
  as_tibble()
mp_results$refs$blast
mp_results$refs$ddmax
mp_results$refs$bfloor

########################
#######################
# test case with GB data
library(tidyverse)
source("R/mp_functions.R")
source("R/get_hydra_data.R")

# create the list of parameters for the MP
settings <- list(
  showTimeSeries = "No",
  useCeiling = "Yes",
  assessType = "stock complex",
  targetF = 0.75,
  floorB = 0.5,
  floorOption = "min status",
  bramp = 0.5,
  blim = 0.1,
  fmin = 0.01,
  floorYrs = 1:40)

#set up some dummy data
#input <- get_om_pars()
input <- NULL
input$Nsp = 10
#om_long <- run_om(input)

# List of Species in Model
# Atlantic_cod
# Atlantic_herring
# Atlantic_mackerel
# Goosefish
# Haddock
# Silver_hake
# Spiny_dogfish
# Winter_flounder
# Winter_skate
# Yellowtail_flounder
feeding_complexes <- tibble(isp = 1:10,
                            complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2))
gear_complexes <- tibble(isp = 1:10,
                         complex = c(1, 3, 3, 1, 1, 3, 1, 2, 1, 2))

input$complex = feeding_complexes$complex

# read in the data
#actual application would use the time series of predictions from hydra
tsfile <- "~/research/hydra_sim/GB-input/hydra_sim_GB_5bin_1978_10F-ts.dat"
index <- read_table(tsfile, skip = 8, n_max = 833, col_names = c("survey" ,"year", "spp", "value" ,"cv")) %>% 
  mutate(var = (value*cv)^2) %>% 
  filter(survey == 1) %>% 
  rename(t = year,
         isp = spp) %>% 
  mutate(type = "biomass") %>% 
  select(t, type, isp, value) %>% 
  left_join(feeding_complexes)
#index
catch <- read_table(tsfile, skip = 1688, n_max = 420, col_names = c("fleet","area","year","spp","catch","cv")) %>% 
  mutate(var = (catch*cv)^2) %>% 
  rename(isp = spp,
         value = catch,
         t = year) %>% 
  mutate(type = "catch") %>% 
  select(t, type, isp, value) %>% 
  left_join(feeding_complexes)
#catch
om_long <- bind_rows(index, catch)

assess_results <- run_pseudo_assessments(om_long). 
#this currently generates data from the predictions, we would want to change so doesn't create new survey/catch time series each application

#call the MP
mp_results <- do_ebfm_mp(settings, assess_results, input)
#remove_rownames() %>%
#ungroup() %>% 
#as_tibble()
mp_results$out_table %>% 
  as_tibble()

#the catch advice, to be passed to get_f_from_advice()
mp_results$out_table$advice

# mp_results$refs$blast
# mp_results$refs$ddmax
# mp_results$refs$bfloor