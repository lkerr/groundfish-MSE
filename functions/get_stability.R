
# Function created to assess stability -- Dichmont et al. Fisheries Res
# 81:235-245 used (nearly) this equation to assess catch stability. They
# accounted for a discount rate however. Represents the percent change in
# landed catches from year-to-year.



get_stability <- function(x){
  ny <- length(x)
  num <- sum(abs(x[2:ny] - x[1:(ny-1)]), na.rm=TRUE)
  den <- sum(x[2:ny], na.rm=TRUE)
  return(num / den)
}


# get_stability(rnorm(10000, 100, 2))
# get_stability(rnorm(10000, 100, 12))

