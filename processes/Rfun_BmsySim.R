


# Recruitment function list for use in the recruitment index column
# of the object mproc (created by the file generateMP.R)

Rfun_BmsySim <- list(
  
  MEAN = function(parpop, ...) mean(parpop$R),
  
  L5SAMP = function(parpop, ...) mean(sample(tail(parpop$R), 5)),
  
  # The median temperature for the Bmsy proxy simulations refers to the
  # median temperature between now and 25 years into the future (if there
  # are 25 years available in the series -- otherwise it just uses what is
  # left).
  
  recT = function(parpop, parenv) 
          get_recruits(type = parpop$Rpar$type, 
          par = parpop$Rpar, 
          S = tail(parpop$SSB, 1),
          tempY = median(parenv$temp[parenv$y:(parenv$y+25)], na.rm=TRUE), 
          stochastic = parenv$Rstoch_ann)['R']
  
)



