# this small file controls some economic options that may vary with the mproc lines.  For example:
  # in the "validation" model runs, we use the "post" production regression, the  "pre" choice equations, post multipliers, prices.  
  # in the counterfactual model runs, we use the "pre" production regression, the  "pre" choice equations, post multipliers, prices.   
  # I've set up a 3rd placeholder option, but  I haven't figured out what to do with it yet.

econtype<-mproc[m,]

myvars<-c("LandZero","CatchZero","EconType","EconData")
econtype<-econtype[myvars]
econ_data_stub<-econtype["EconData"]
if (econ_data_stub=='validation'){
  multiplier_loc<-"sim_multipliers_post_valid.Rds"
  output_price_loc<-"output_prices_post_valid.Rds"
  input_price_loc<-"input_prices_post_valid.Rds"
  production_vars<- production_vars_post
  spstock_equation<-spstock_equation_pre
  choice_equation<-choice_equation_pre
  # Read in Economic Production Data. These are relatively lists of data.tables. So it makes sense to read in once and then list-subset [[]] later on.
  
} else if (econ_data_stub=='counterfactual'){
  multiplier_loc<-"sim_multipliers_pre_CF.Rds"
  output_price_loc<-"output_prices_post_CF.Rds"
  input_price_loc<-"input_prices_post_CF.Rds"
  production_vars<-production_vars_pre
  spstock_equation<-spstock_equation_pre
  choice_equation<-choice_equation_pre
  
} else if (econ_data_stub=='full_targeting'){
  multiplier_loc<-"sim_multipliers_post_MSE.Rds"
  output_price_loc<-"output_prices_post_MSE.Rds"
  input_price_loc<-"input_prices_post_valid.Rds"
  production_vars<-production_vars_post
  spstock_equation<-spstock_equation_pre
  choice_equation<-choice_equation_pre
  
}
multipliers<-readRDS(file.path(econdatapath,multiplier_loc))
outputprices<-readRDS(file.path(econdatapath,output_price_loc))
inputprices<-readRDS(file.path(econdatapath,input_price_loc))
