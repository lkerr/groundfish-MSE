

# get_M: Function to assign natural mortality values to age classes. Function
#        returns a vector the same length as the input vector L. Options
#        'fixed' and 'Pauly' return vectors that do not vary by size. Options
#        'Pauly' and 'GislasonM3' include a temperature effect.
# 
#   * type: type of mortality function to be applied. Options are:
#   
#       * fixed: fixed mortality rate over time. The same value will be
#                applied to all age classes. Vector of lengths must still 
#                be applied so that the appropriate vector length is output.
#                
#       * Pauly: use Pauly's relationship (Pauly 1980)
#       
#       * GislasonM1: Gislason's model 1 (Gislason 2010, Table 1)
#       
#       * GislasonM2: Gislason's model 2 (Gislason 2010, Table 1). This is 
#                     Gislason's recommended version.
#       
#       * GislasonM3: Gislason's model 3 (Gislason 2010, Table 1). Model 3
#                     includes a temperature effect.
#                     
#   * par: named vector of model parameters including
#   
#       * M for method 'fixed' -- this is the fixed natural mortality rate
#         across all ages
#         
#       * Linf: von Bertalanffy L-infinity for Pauly and all Gislason
#               methods
#               
#       * K: von Bertalanffy K for Pauly and all Gislason methods
#       
#   * data: list of data necessary for calculations including:
#   
#       * L: vector of length-at-age necessary for all methods, even 'fixed'
#            where M does not vary by age or size
#            
#       * Temp: value for temperature necessary for methods 'Pauly' and
#               'GislasonM3'



get_M <- function(type, par, data){
  
  if(is.null(data$Temp) & type != 'fixed'){
    stop('get_M: If <type> is not <fixed> then must provide temperature')
  }
  
  if(type == 'fixed'){
    
    out <- rep(par['M'], length = length(data$L))
    
  }
  
  if(type == 'Pauly'){
  
    log10M <- -0.0066 - 0.279 * log10(par['Linf']) + 
              0.6543 * log10(par['K']) + 0.4634 * log10(data$Temp)
    
    out <- rep(10^log10M, length = length(data$L))
    
  }else if(type == 'GislasonM1'){
  
    logM <- 0.61 - 1.61 * log(data$L) + 1.39 * log(par['Linf']) + 
            0.91 * log(par['K']) + 0*data$Temp
    
    out <- c(M = exp(logM))
  
  }else if(type == 'GislasonM2'){
    
    logM <- 0.55 - 1.61*log(data$L) + 1.44*log(par['Linf']) + 
            1*log(par['K']) + 0*data$Temp
    
    out <- c(M = exp(logM))
    
  }else if(type == 'GislasonM3'){
    
    logM <- 15.11 - 1.59*log(data$L) + 0.82*log(par['Linf']) - 
            3891/(data$Temp + 273.15)
    
    out <- c(M = exp(logM))
    
  }
  
  return(out)
  
}



#### Test the model

type <- 'GislasonM3'
L <- 50

## 'Pauly'
## 'GislasonM1'
## 'GislasonM2'
## 'GislasonM3'


# Testing data
cmip5 <- read.table(file='data/data_raw/NEUS_CMIP5_annual_means.txt',
                    header=TRUE, skip=2)
laa_par <- c(Linf=114.1, K=0.22, t0=0.17, beta1=5)


# Apply the function to the range of CMIP temperature values
cmipM <- sapply(2:ncol(cmip5), function(x)
                            get_M(type = type,
                                  par = laa_par,
                                  Temp = cmip5[,x],
                                  L = L))

# Calculate the mean and the sd
meanM <- apply(cmipM, 1, mean)
sdM <- apply(cmipM, 1, sd)

# Calculate the deviation range for plotting
rg <- range(meanM, meanM+sdM, meanM-sdM)


## Create a plot

plot(meanM ~ cmip5$year, type = 'n', ylim=rg, xaxs='i',
     las = 1, xlab = 'Year', ylab = 'M',
     main = type)

polygon(x = c(cmip5$year, rev(cmip5$year)),
        y = c(meanM - sdM, rev(meanM + sdM)),
        col = 'cornflowerblue', border = 'firebrick1')
box()

lines(meanM ~ cmip5$year, col='firebrick1', lwd=3)



## Size-based M for Gisluson models

L <- seq(40, 150, 5)

typs <- c('GislasonM1', 'GislasonM2', 'GislasonM3')
LM <- sapply(typs, function(x)
                     get_M(type = x,
                     par = laa_par,
                     Temp = 18,
                     L = L))

matplot(L, LM, type = 'l', lty = 1, col = 1:3, lwd=3, las=1)

legend('topright',
       legend = typs,
       lty = 1,
       col = 1:3,
       bty = 'n',
       lwd = 3)
