



# ages: 
#
# type: "age" or "length" -- governs whether the output selectivity is
#       age- or length-based. (Selectivity always length-based ... this just
#       governs what the plot looks like because you may want to compare
#       to age-based selectivities in actual assessments.
#       
# laa_typ: type of length-at-age model (see get_lengthAtAge)
# 
# laa_par: length-at-age parameters (see get_lengthAtAge)
# 
# selC_typ: type of selectivity function (see get_slx)
# 
# selC_par: selectivity-at-length parameters (see get_slx)
# 
# TAnom: temperature anomoly to use in the length-at-age function


get_slxPlot <- function(ages, type, laa_typ, laa_par, 
                        selC_typ, selCpar, TAnom){
 
  
  if(!type %in% c('length', 'age')){
    stop('get_slxPlot: argument type should be either age or length')
  }
  
  laa <- get_lengthAtAge(type=laa_typ, par=laa_par, 
                  ages=fage:page, Tanom=TAnom)
  
  slx <- get_slx(type=selC_typ, par=selCpar, laa=laa)
  
  if(type == 'age'){
    
    xlab <- 'Age'
    xval <- ages
    
  }else{
  
    xlab <- 'Length'
    xval <- laa
    
  }
  
  ylab <- 'Selectivity'
    
  plot(slx ~ xval, las=1, pch=4, cex=1.25, lwd=2, ylab=ylab, xlab=xlab)
  
}