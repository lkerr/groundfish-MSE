# Setting up the data.
# Before you do anything, you put these files into the 
# /data/data_raw/econ folder
 
    # data_for_simulations_mse.dta (main data file)
    # multipliers.dta (multipliers)
    # production_regs_actual_post_for_R.txt (production coefficients)
    # preCSasclogit2.ster
    # postCSasclogit2.ster


# This bit of code will run some stata.  
stata_exec<-"/usr/local/stata15/stata-mp"
#This one for windows0
#stata_opts<-" /b do" 
#this one for *nix
stata_opts <- "-b do"
stata_codedir <-"/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/preprocessing/economic"
#stata_dofiles<-c("wrapper.do")
stata_dofiles<-c("asclogit_coef_export.do", "stocks_in_model.do", "recode_catch_limits.do", "multiplier_prep.do","price_prep.do","econ_data_split.do")
stata_dofiles_list<-as.list(stata_dofiles)


# The lapply method hung, but it might just be that my code takes a long time.
# readin <-function(files){
#   full_cmd<-paste(stata_exec, stata_opts,file.path(stata_codedir,files) , sep=" ") 
#   system(full_cmd, timeout=0, intern=FALSE)
# }
# lapply(stata_dofiles, readin)

# This works, and satisfies my impatience to see some stuff appear on the screen.
for (i in stata_dofiles) {
     full_cmd<-paste(stata_exec, stata_opts,file.path(stata_codedir,i) , sep=" ") 
     system(full_cmd, timeout=0, intern=FALSE)
     print (paste("done with", i))
}



source('preprocessing/economic/targeting_coeff_import.R')
source('preprocessing/economic/production_coefs.R')

source('preprocessing/economic/price_import.R')
source('preprocessing/economic/multiplier_import.R')
source('preprocessing/economic/vessel_specific_prices.R')

source('preprocessing/economic/targeting_data_import.R')

