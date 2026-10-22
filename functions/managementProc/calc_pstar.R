calc_pstar = function(relB)#function to calculate P* based on SSB/SSBmsy
{ # updated to represent MAFMC approach: https://d23h0vhsm26o6d.cloudfront.net/2a.-Muffley-Risk-Policy-to-NEFMC_01_24.pdf
  if(relB>= 1.5) #at asymptote
  {
    P = 0.49
  }
  else if(relB < 1.5 & relB >= 1.0)
  {
    P = 0.37+0.08*relB # linear regression from 0.45 to 0.49
  }
  else
  {
    P = -0.05+0.5*relB # linear regression from 0 to 0.45
  }
  return(P)
}