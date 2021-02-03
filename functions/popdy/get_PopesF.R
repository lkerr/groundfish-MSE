

# Function to calculate Popes approximation of Fishing mortality from catch
# 
#
# Arguments:
# yield: yield in year y
#
# naa: numbers-at-age 
#
# waa: weight-at-age
#
# saa: selectivity-at-age
#
# M: natural mortality
#
# ra: reference ages to average Faa across

# 1.	Start with target yield (in biomass)
# 2.	derive mean weight of catch in year y from OM, meanW=sumproduct(Na x Wa x Va)/sum(N x Va)
# 3.	derive target catch (in numbers) C=Y/meanW
# 4.	derive catch at age =C x ((Na x Va)/sumproduct(Na x Va))
# 5.	derive survivors N(a+1,y+1)=(Na x exp(-Ma/2)-Ca) x exp(-Ma/2)
# 6.	derive Fa=Ln(Na/Na,y+1)-Ma
# 7.	use F at fully-selected age as target F.



get_PopesF  <- function(yield, naa, waa, saa, M, ra) {
  
  
  ## calcualte mean weight
  #calculate mean catch weight  
   mean_weight <- sum(naa * waa * saa) / sum(naa *saa)
  
  # calculate target catch
  targ_catch <- yield/mean_weight
  
  # calculate catch-at-age
  caa <- targ_catch * ((naa * saa)/sum(naa *saa))

  # calc Maa
  Maa <- rep(M, length(naa))
  
  # calculate survivors 
  surv <- (naa * exp(-Maa/2)- caa) * exp(-Maa/2)
  
  # fishing mortality-at-age 
  Faa <- log(naa/surv) - Maa 
 
  # calculate average Faa from reference ages 
  ref_F <- mean(Faa[ra])
  
  
  return(ref_F)
  
}
#### end