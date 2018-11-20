


# Recruitment function list for use in the recruitment index column
# of the object mproc (created by the file generateMP.R)

Rfun_BmsySim <- list(
  
  MEAN = function(parpop, ...) mean(parpop$R),
  
  L5SAMP = function(parpop, ...) mean(sample(tail(parpop$R), 5)),
  
  recT = get_recruits(type = parpop$Rpar$type, par = parpop$Rpar, 
                      S = tail(parpop$SSB, 1),
                      tempY = parenv$temp[parenv$y], 
                      stochastic = parenv$Rstoch_ann)
  
)



