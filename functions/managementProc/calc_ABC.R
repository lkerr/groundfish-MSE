calc_ABC <- function(OFL, P, CV)
{
  # OFL is the median catch by fishing at Flim for the current population
  #Convert CV to sigma for lognormal dist
  sd <- sqrt(log(CV*CV+1))
  #Calculate ABC using inverse of the lognormal dist
  return(qlnorm(P, meanlog = log(OFL), sdlog = sd))
}