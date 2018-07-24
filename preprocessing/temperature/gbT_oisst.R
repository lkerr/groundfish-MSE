






# Load in the GB oisst data
load('data/data_raw/gb.dat.Rdata')

# Aggregate into monthly averages and quarterly averages
m <- tapply(gb.df$Temp, INDEX=list(gb.df$Year.Clean, gb.df$Month), 
            FUN=mean, na.rm=TRUE)
qnum <- list(1:3, 4:6, 7:9, 10:12)

q <- sapply(qnum, function(x) apply(m[,x], 1, mean))

# Combine into matrix with monthly and quarterly temps
mqt <- cbind(m, q)
mqt <- cbind(as.numeric(row.names(mqt)), mqt)
colnames(mqt) <- c('Year', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                   'q1', 'q2', 'q3', 'q4')
rownames(mqt) <- NULL
mqt_oisst <- as.data.frame(mqt)

save(mqt_oisst, file='data/data_raw/mqt_oisst.Rdata')
