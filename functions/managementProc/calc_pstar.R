calc_pstar = function(maxp, relB)#function to calculate P* based on SSB/SSBmsy
{
  if(relB>=1) #at asymptote
  {
    P = maxp
  }
  else if(relB<=0.1)
  {
    P = 0.0
  }
  else
  {
    slope <- (maxp)/(1-0.1)
    inter <- maxp-slope
    P = inter+slope*relB
  }
  return(P)
}