


# Recruitment function list for use in the recruitment index column
# of the object mproc (created by the file generateMP.R)

Rfun_BmsySim <- list(
  
  MEAN = mean,
  
  L5SAMP = function(x) mean(sample(tail(x), 5)),
  
  recT = get_recruits(type=Rpar$type, par=Rpar, S=SSB[y],
                      tempY=temp[y], stochastic=Rstoch_ann)
  
)



