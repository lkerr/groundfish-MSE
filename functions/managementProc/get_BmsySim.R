

# Function to get Bmsy assuming an Fmsy, recruitment history and level of
# natural mortality.
# 
# parmgt: a 1-row data frame of management parameters. The operational
#         component of parmgt for this function are the (1-row) columns
#         "FREF_TYP" and "FREF_LEV". FREF_TYP/FREF_LEV determine
#         how the Fmsy proxy is set (i.e., what the level of fishing
#         mortality will be during the projections).
# 
# parpop: named ist of population parameters (vectors) needed for the 
#         simulation including selectivity (sel), weight-at-age (waa),
#         recruitment (R), maturity (mat) and natural mortality (M).
#         Natural mortality can be a vector or a scalar. Vectors have
#         one value per age class.
# 
# Rfun: Function defining what to do with the recruitment histories. Any 
#       function will do here, and extra arguments can be included using
#       the (...). A common function will be sample(), with size=1 included
#       as an extra argument. That just means a random draw from the
#       recruitment history. You could also use mean() or mean() with
#       the trim=p argument in the ... if you wanted to apply the mean
#       recruitment or a trimmed mean recruitment to every year of the
#       projection/simulation. Another option would be to do something 
#       like use rlnorm() and then specify an sd. Or you could define a
#       trend in the recruitment history and use that.
#       
# distillBmsy: function to aggregate biomasses under the particular F policy.
#              Since temperature can play a role there is no equilibrium
#              over the period, so need to make a decision about what function
#              to use like mean, median or a quantile.
#       
#         
#         
# # Important note: If you want to use only the last n years of the
# recruitment history, you can use something like
#     function(x) sample(tail(x, n), 1)
# as Rfun. But note that if you ever only wanted to apply this function
# to the very last year (i.e., n=1), sample will not work because,
# for example, sample(5, n=1) samples the vector 1:5 rather than the
# number 5. Probably you wouldn't really want to use the last year
# anyhow though (so I guess this note isn't so critically important!)


### ** note: initial numbers-at-age is assuming age-1 is the minimum right now. model ages should be
###          passed under parpop and the minimum should be used instead of 1.0.



get_BmsySim <- function(parmgt, parpop, parenv, Rfun,
                        F_val, distillBmsy = mean, ...){

  
  get_proj(parmgt = parmgt, 
           parpop = parpop, 
           parenv = parenv, 
           Rfun = Rfun,
           F_val = Fprox['RPvalue'],
           stReportYr)
  

  # Find the total SSB / year ([-1,] to get rid of the initial year, where
  # recruitment was coming out of an estimate and had nothing to do with
  # any projections.
  SSBref <- distillBmsy(apply(SSBaa, 1, sum))
 

  out <- list(RPlevel = parmgt$FREF_LEV,
              RPvalue = F_val,
              SSBvalue = SSBref,
              meanSumCW = mean(sumCW))
  
  return(out)
  
}


