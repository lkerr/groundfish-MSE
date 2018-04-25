


bbh_base <- read.csv('data/1905-2017sst-3-5-18.csv', stringsAsFactors = FALSE)
sr <- read.csv('data/SAW55SR.csv')

mdy <- as.data.frame(do.call(rbind, strsplit(bbh_base$COLLECTION_DATE, split='\\/')))
qtab <- cbind(1:12, rep(1:4, each=3))
names(mdy) <- c('MONTH', 'DAY', 'YEAR')
mdy$Q <- qtab[match(as.numeric(as.character(mdy$MONTH)), qtab[,1]),2]


bbh <- cbind(mdy, bbh_base)


# get Q1 - Q4 median temp
bbhyv <- data.frame(tapply(bbh$Sea.Surface.Temp.Ave.C, 
                           INDEX=list(mdy$YEAR, mdy$Q), 
                           FUN=median, na.rm=TRUE))
bbhyv$Year <- row.names(bbhyv)
names(bbhyv) <- c('Q1', 'Q2', 'Q3', 'Q4', 'Year')


srt <- merge(sr, bbhyv)
names(srt)[names(srt) == 'SSBMT'] <- 'S'
names(srt)[names(srt) == 'A1Recruitmentx1000'] <- 'R'
srt$R <- srt$R * 1000 # get the true recruitment

idxSSB <- 1:(nrow(srt)-1)
idxR <- 2:nrow(srt)


logRS <- log(srt$R[idxR] / srt$S[idxSSB])

lm <- lm(logRS ~ srt$S[idxSSB] + srt$Q3[idxSSB])
lmpar <- coef(lm)
Rhat <- srt$S[idxSSB] * exp(predict(lm))

# make a plot

rS <- range(srt$S)
newS <- seq(0, rS[2]*2, length.out=250)
newT <- c(10, 15, 20)
newR <- sapply(1:length(newT), function(x){
  newS * exp(lmpar[1] + lmpar[2]*newS + lmpar[3]*newT[x])
})


sclR <- 1000000
sclS <- 1000

par(mar=c(4,4,2,1))
plot(0, type='n', xlim=range(newS/sclS), ylim=c(0, max(newR)/sclR),
     xlab='', ylab='', las=1)
matplot(x=newS/sclS, y=newR/sclR, type='l', lwd=3, add=TRUE)

points(srt$S[idxSSB]/sclS, srt$R[idxR]/sclR, pch=3)

mtext(side=1:2, line=c(2.5,2.5), cex=1.25,
      c('SSB (MTx1000)', 'R (millions)'))
legend('top', xpd=NA, col=1:3, lty=1:3, bty='n', ncol=3, lwd=2,
       legend=paste('T=', newT),
       yjust=0, inset=-0.2)





