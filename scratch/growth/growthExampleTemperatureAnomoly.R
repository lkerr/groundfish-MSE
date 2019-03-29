

source('functions/get_lengthAtAge.R')

a <- 1:20
T <- seq(0,3, length.out=5)

p0 <- c(Linf=114.1, K=0.22, t0=0.17)
L1 <- c(Linf=114.1, K=0.22, t0=0.17, beta1=1)
L2 <- c(Linf=114.1, K=0.22, t0=0.17, beta1=5)
K1 <- c(Linf=114.1, K=0.22, t0=0.17, beta2=0.01)
K2 <- c(Linf=114.1, K=0.22, t0=0.17, beta2=0.05)


m0 <- get_lengthAtAge(type='vonB', par=p0, ages=a)

mL1 <- t(sapply(1:length(T), 
                function(i) get_lengthAtAge(type='vonB', par=L1, 
                                            ages=a, Tanom=T[i])))
mL2 <- t(sapply(1:length(T), 
                function(i) get_lengthAtAge(type='vonB', par=L2, 
                                            ages=a, Tanom=T[i])))
mK1 <- t(sapply(1:length(T), 
                function(i) get_lengthAtAge(type='vonB', par=K1, 
                                            ages=a, Tanom=T[i])))
mK2 <- t(sapply(1:length(T), 
                function(i) get_lengthAtAge(type='vonB', par=K2, 
                                            ages=a, Tanom=T[i])))

yl <- range(m0, mL1, mL2, mK1, mK2)
par(mar=c(0,0,0,0), oma=c(5,5,1,1), mfrow=c(2,2))

colf <- colorRampPalette(c('darkblue', 'lightblue'))
col <- colf(length(T))

plot(m0 ~ a, ylim=yl, type='l', lwd=3, col='gray30', axes=FALSE)
axis(2, las=1)
matlines(a, t(mK1), lwd=1, col=col, lty=1)
box()

plot(m0 ~ a, ylim=yl, type='l', lwd=3, col='gray30', axes=FALSE)
matlines(a, t(mK2), lwd=1, col=col, lty=1)
box()

plot(m0 ~ a, ylim=yl, type='l', lwd=3, col='gray30', axes=FALSE)
matlines(a, t(mL1), lwd=1, col=col, lty=1)
axis(1)
axis(2, las=1)
box()

plot(m0 ~ a, ylim=yl, type='l', lwd=3, col='gray30', axes=FALSE)
axis(1)
matlines(a, t(mL2), lwd=1, col=col, lty=1)
box()

mtext(side=1:2, line=3, cex=1.25, c('Age', 'Length'), outer=TRUE)
