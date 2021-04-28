
# Function to return weight-at-age.
# 
# laa: vector of lengths-at-age
# 
# type: type of function function. Available options are
#       *'aLb'
#        W = par[1] * L^par[2]
#       *''
#       *'input'
#       use vector of weight-at-age, must be same length as number of age classes
#
# par: vector of parameters to use in the function. See function
#      definitions in "type" for the length of the vector and
#      how the function is parameterized
#      
# inputUnit: units for laa vector. Output should be in MT
#           * kg for kilograms
#           * mt for metric tons
#      


get_weightAtAge <- function(type, par, laa, inputUnit,y,fmyearIdx){
  
  if(type == 'aLb'){

    waa <- par[1] * laa ^ par[2]

  }
  else if(type == 'input'){
    
    waa <- par[1:length(par)]
  
    
    }
  else if(type == 'change'){
    if (y<fmyearIdx){
    waa <- par[1:9]
    }
  else{waa<-par[10:18]}
    
  }
  else if(type == 'dynamic'){
    waamat<-as.matrix(read.csv('data/data_raw/waamatrix.csv'))
    colnames(waamat)<-NULL
    if (y<82){waa <- waamat[1,]}
    else if (y>81 & y<169){waa <- waamat[(y-81),]}
    else if (y>168){
      #waa<-par
      waa<-waamat[87,]
      T<-tAnomOut$T[tAnomOut$YEAR==y+1850]
      waa1<-(-0.22671*T)+4.23953
      if (waa1>waa[1]){waa1<-waa[1]}
      waa2<-(-0.4229*T)+8.0404
      if (waa2>waa[2]){waa2<-waa[2]}
      waa3<-(-0.5745*T)+11.0307
      if (waa3>waa[3]){waa3<-waa[3]}
      waa4<-(-0.8249*T)+15.6581
      if (waa4>waa[4]){waa4<-waa[4]}
      waa5<-(-1.1238*T)+21.0681
      if (waa5>waa[5]){waa5<-waa[5]}
      waa6<-(-1.3378*T)+25.0079
      if (waa6>waa[6]){waa6<-waa[6]}
      waa7<-(-1.6141*T)+30.0517
      if (waa7>waa[7]){waa7<-waa[7]}
      waa8<-(-1.8090*T)+33.6327
      if (waa8>waa[8]){waa8<-waa[8]}
      waa9<-(-2.2019*T)+40.7899
      if (waa9>waa[9]){waa9<-waa[9]}
      waa<-c(waa1,waa2,waa3,waa4,waa5,waa6,waa7,waa8,waa9)
    }
  }
  else{

    stop('weight-at-age type not recognized')
  
  }
  
  if(tolower(inputUnit) == 'kg'){
    
    waa <- waa / 1000
    
  }else if(tolower(inputUnit) == 'mt'){

    # do nothing 
  }else{
    
    stop('get_weightAtAge: fix inputUnit')
    
  }
  
  return(waa)
   
}





