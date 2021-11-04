getCW <- function(logF){

F <- exp(logF)

# First calculate the components of the catch equation

# Fraction of dead fish that come from fishing
fracF <- slxCv * F / (slxCv * F + M)

# Fraction of dead fish in the population
fracDead <- 1 - exp(-slxCv * F - M)

# Catch in weight by age
CWaa <- fracF * fracDead * Nv * waav

# Total catch
CW <- sum(CWaa)

# Calculate the difference from the total weight we are trying to
# match
diff <- abs(x - CW)

return(diff)

}