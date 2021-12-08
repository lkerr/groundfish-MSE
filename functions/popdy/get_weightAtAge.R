#' @title Generate Weight-at-Age Vector
#' @description Calculate and return weight-at-age
#' 
#' @param type A string indicating the method used to generate weight-at-age
#' \itemize{
#'   \item{"aLb" - Weight calculated: W = par[1] * L^par[2]}
#'   \item{"input" - Use weight-at-age provided in par}
#'   \item{"change" - Changes weight-at-age over time ???}
#'   \item{"dynamic" - Draws from matrix, in final year uses par ???}
#' }
#' @param par A vector of parameters used to calculate weight-at-age, dependent on selected type:
#' \itemize{
#'   \item{If type = "aLb", par contains two parameters a and b to describe weight-length relationship}
#'   \item{If type = "input" or "dynamic", par is a vector of weight-at-age to use, must be same length as number of age classes}
#'   \item{If type = "change", par is a vector}
#' }
#' @param laa A vector of lengths-at-age
#' @param inputUnit A string indicating the units for the laa vector, options include:
#' \itemize{
#'   \item{"kg" - for kilograms}
#'   \item{"mt" - for metric tons}
#' }
#' @template global_y
#' @template global_fmyearIdx
#' 
#' @return A vector of weight-at-age in metric tons
#' 
#' @family operatingModel, population
#' 
#' @export

get_weightAtAge <- function(type, 
                            par, 
                            laa, 
                            inputUnit, 
                            y, 
                            fmyearIdx){
  
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
    waamat<-as.matrix(read.csv('data/data_raw/waamatrix.csv')) #!!! Probably want this to be a data input OR reference .rda object from package
    colnames(waamat)<-NULL
    if (y<82){
      waa <- waamat[1,]
    }else if (y>81 & y<169){
      waa <- waamat[(y-81),]
    }else if(y>168){
      waa<-par
      #waa<-waamat[87,]
      #T<-tAnomOut$T[tAnomOut$YEAR==y+1850]
      #waa1<-(-0.22671*T)+4.23953
      #if (waa1>waa[1]){waa1<-waa[1]}
      #waa2<-(-0.4229*T)+8.0404
      #if (waa2>waa[2]){waa2<-waa[2]}
      #waa3<-(-0.5745*T)+11.0307
      #if (waa3>waa[3]){waa3<-waa[3]}
      #waa4<-(-0.8249*T)+15.6581
      #if (waa4>waa[4]){waa4<-waa[4]}
      #waa5<-(-1.1238*T)+21.0681
      #if (waa5>waa[5]){waa5<-waa[5]}
      #waa6<-(-1.3378*T)+25.0079
      #if (waa6>waa[6]){waa6<-waa[6]}
      #waa7<-(-1.6141*T)+30.0517
      #if (waa7>waa[7]){waa7<-waa[7]}
      #waa8<-(-1.8090*T)+33.6327
      #if (waa8>waa[8]){waa8<-waa[8]}
      #waa9<-(-2.2019*T)+40.7899
      #if (waa9>waa[9]){waa9<-waa[9]}
      #waa<-c(waa1,waa2,waa3,waa4,waa5,waa6,waa7,waa8,waa9)
    }
  } else{

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
