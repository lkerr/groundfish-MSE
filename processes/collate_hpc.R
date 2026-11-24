##### Collate results for iterations run in parrallel on UMaine HPC
# Should work for any number of iterations with .rds files in the directory, and different results output across MSE branches
# However:
# across the structure of results lists must be consistent across the .rds files
# within each .rds file, the results should be stored as a list of dataframes

library(purrr)
library(dplyr)
library(stringr)

source('processes/identifyResultDirectory.R')
setwd(ResultDirectory)

# find all .rds files
file_names <- list.files(pattern = "res_for_plots")

# get the datetime and array job tag
patterns <- c("res_for_plots_", "_[^_]*$") # patterns to remove ("_[^_]*$" is the last underscore and everything after it)
tag <- str_remove_all(file_names[1], paste(patterns, collapse = "|"))

# create a new output directory one level outside of the github repository

##### This directory managmenent is not working!!!!!!! 
# collated results get saved, but inside multiple nested directories in the original results directory
path <- ResultDirectory %>% str_remove("groundfish-MSE.*") 
outdir <- if_else(str_ends(path, "/"), path, str_c(path, "/")) %>%
  str_c("results_", tag)

print(paste("base directory path is:", path))
print(paste("Ouput directory is: "), outdir))

if(!dir.exists(outdir)){dir.create(outdir, recursive = T)}


########## load all .rds results files and collate them
iteration_results <- lapply(file_names, readRDS) %>% set_names(file_names)
collated_results <- list_transpose(iteration_results) %>% map(bind_rows)

filepath <- paste0(outdir, "/collated_results_", tag, ".rds")
print(paste("File path name is: "), filepath))
# save results to the output directory
saveRDS(collated_results, file = filepath)



### could add summarizing to median, mean, and uncertainty across iterations??