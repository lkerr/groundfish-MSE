# this small file controls some economic options that may vary with the mproc lines.  For example:
  # in the "validation" model runs, we use the "post" production regression, the  "pre" choice equations, post multipliers, prices.  
  # in the counterfactual model runs, we use the "pre" production regression, the  "pre" choice equations, post multipliers, prices.   
  # I've set up a 3rd placeholder option, but  I haven't figured out what to do with it yet.

myvars<-c("LandZero", "CatchZero","EconType","EconName","EconData","MultiplierFile","OutputPriceFile","InputPriceFile","ProdEqn","ChoiceEqn")
econtype<-econtype[myvars]
econ_data_stub<-econtype$EconData

multiplier_loc<-econtype$MultiplierFile
output_price_loc<-econtype$OutputPriceFile
input_price_loc<-econtype$InputPriceFile


# you need to fix this so it flexibly reads in the vectors
production_vars<-get(paste0("production_vars_",econtype$ProdEqn))
spstock_equation<-get(paste0("spstock_equation_",econtype$ChoiceEqn))
choice_equation<-get(paste0("choice_equation_",econtype$ChoiceEqn))

multipliers<-readRDS(file.path(econdatapath,multiplier_loc))
outputprices<-readRDS(file.path(econdatapath,output_price_loc))
inputprices<-readRDS(file.path(econdatapath,input_price_loc))
