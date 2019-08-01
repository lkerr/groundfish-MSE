

get_bdata <- function(bouyfpath){

  # load the GB buoy data
  fdata <- list.files(path=bouyfpath, full.names=TRUE)
  
  bdataread <- lapply(1:length(fdata), function(x){
                         r <- read.table(fdata[x], header=TRUE, sep='')
                         rout <- r[,c('YYYY', 'MM', 'DD', 'WTMP')]
                         if(nchar(rout$YYYY[1])<4){
                           rout$YYYY <- as.numeric(paste0(19,rout$YYYY))
                         }
                         # print(x)
                         return(rout)
                       })
  
  
  # combine the years
  bdata <- do.call(rbind, bdataread)
  

  # organize data into wide format 
  library(reshape2)
 
  gbw <- dcast(bdata, 
               formula = YYYY ~ MM,
               value.var = 'WTMP',
               fun.aggregate = median, na.rm=TRUE)
  names(gbw) <- c('Year', paste0('m', names(gbw)[2:ncol(gbw)]))

  # function to calculate quarterly means
  qmean <- function(m){
    nms <- paste0('m', m)
    sapply(1:nrow(gbw), function(x) mean(unlist(gbw[x,nms])))
  }
  
  # get the quarterly means
  gbw$q1 <- qmean(m=1:3)
  gbw$q2 <- qmean(m=4:6)
  gbw$q3 <- qmean(m=7:9)
  gbw$q4 <- qmean(m=10:12)
  
  return(gbw)

}


b44008 <- get_bdata(bouyfpath='data/gbBuoyData/44008/')
b44011 <- get_bdata(bouyfpath='data/gbBuoyData/44011/')

# identify the years in all
yia <- union(b44008$Year, b44011$Year)
wyic08 <- yia %in% b44008$Year
wyic11 <- yia %in% b44011$Year

# dmat08 <- matrix(NA, nrow=length(yia), ncol=ncol(b44008))
# dmat11 <- matrix(NA, nrow=length(yia), ncol=ncol(b44011))

dmat <- array(NA, dim=c(length(yia), ncol(b44008),2))
dmat[wyic08,,1] <- as.matrix(b44008)
dmat[wyic11,,2] <- as.matrix(b44011)
gbTmat <- apply(dmat[,2:dim(dmat)[2],], 1:2, mean, na.rm=TRUE)
gbTmat[is.nan(gbTmat)] <- NA
gbT <- data.frame(cbind(yia, gbTmat))
names(gbT) <- names(b44008)



save(gbT, file='data/data_processed/gbT.Rdata')
