#Data to save for later
saveData <- function(OMScenario,RhoScenario,FreqScenario,HCR) {
  #Gather outputs (medians and upper and lower confidence intervals)
  SSBObs<-Df$SSBObs[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  FObs<-Df$FObs[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  CatchObs<-Df$CatchObs[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  RObs<-Df$RObs[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  SSBEst<-Df$SSBEst[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  FEst<-Df$FEst[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  CatchEst<-Df$CatchEst[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  REst<-Df$REst[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  SSBObs_CIUpper<-Df$SSBObs_CIUpper[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  FObs_CIUpper<-Df$FObs_CIUpper[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  CatchObs_CIUpper<-Df$CatchObs_CIUpper[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  RObs_CIUpper<-Df$RObs_CIUpper[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  SSBObs_CILower<-Df$SSBObs_CILower[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  FObs_CILower<-Df$FObs_CILower[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  CatchObs_CILower<-Df$CatchObs_CILower[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  RObs_CILower<-Df$RObs_CILower[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  SSBREE<-Df$SSBREE[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  FREE<-Df$FREE[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  SSBMohn<-Df$SSBMohn[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  FMohn<-Df$FMohn[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  #Gather outputs (N values for each year, n= # of iterations)
  SSBRatioObs<-Df$SSBRatioObs[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  FRatioObs<-Df$FRatioObs[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  SSBRefErr<-Df$SSBRefErr[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]
  FRefErr<-Df$FRefErr[Df$OMScenario==OMScenario & Df$RhoScenario==RhoScenario & Df$FreqScenario==FreqScenario & Df$HCR==HCR,]

  OMScenario<-rep(OMScenario,21)
  RhoScenario<-rep(RhoScenario,21)
  FreqScenario<-rep(FreqScenario,21)
  HCR<-rep(HRC,21)
  #Put into dataframe
  data<-as.data.frame(cbind(OMScenario,RhoScenario,FreqScenario,HCR,SSBObs,FObs,CatchObs...))
  colnames(data)<-c(...)
  #Join dataframe with existing dataframe
  if (exists("responses")) {
    responses <<- rbind(responses, data)
  } else {#otherwise create new dataframe
    responses <<- data
  }
}