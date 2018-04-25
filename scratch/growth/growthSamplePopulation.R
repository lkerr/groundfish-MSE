

# simulated growth data that is impacted by temperature

nsamp <- 30
nyear <- 50
Z <- 0.4

Linf <- 150.93
K <- 0.11
t0 <- -0.13

nR <- 100
mxage <- 20

L1sd <- 0.5

theta <- c(10, 5, 1)

residsd <- 3
ar1rho <- 0.5

thetav <- c(theta, rep(0, mxage-length(theta)))

tbase <- seq(15, 20, length.out=nyear)
tresid <- rnorm(1, 0, residsd)
for(i in 2:nyear){
  tresid[i] <- rnorm(1, ar1rho * tresid[i-1], sd=residsd)
}

temp <- tbase + tresid

tanom <- temp - mean(temp)




iage <- rpois(nR*5, lambda=5)
ilen <- Linf * (1 - exp(-K * (iage - t0)))
pop <- rep(list(list(STAT=1, 
                     ALDAT=data.frame(YEAR=NA, AGE=NA, LEN=NA))), nR*5)
for(i in 1:length(pop)){
  pop[[i]]$ALDAT$YEAR <- 0
  pop[[i]]$ALDAT$AGE <- iage[i]+1
  pop[[i]]$ALDAT$LEN <- ilen[i]
}

for(y in 1:nyear){
  for(n in 1:length(pop)){
    pop[[n]]$STAT <- rbinom(1,1,exp(-Z))
    if(tail(pop[[n]]$ALDAT$AGE, 1) == mxage){
      pop[[n]]$STAT <- 0
    }
    if(pop[[n]]$STAT == 1){
      tt <- pop[[n]]$ALDAT
      L0 <- tt[nrow(tt),3]
      age <- tt$AGE[nrow(tt)]
      inc <- ((Linf - L0) * (1 - exp(-K)) +
              tanom[y] * thetav[age]) *
              rlnorm(1, meanlog=-L1sd/2, L1sd)
      L1 <- L0 + inc
      nxt <- data.frame(YEAR=y, AGE=tt[nrow(tt),2]+1, LEN=L1)
      pop[[n]]$ALDAT <- rbind(tt, nxt)
    }
  }
  newR <- rep(list(list(STAT=1, 
                        ALDAT=data.frame(YEAR=NA, AGE=NA, LEN=NA))), nR)
  for(i in 1:length(newR)){
    newR[[i]]$ALDAT <- data.frame(YEAR=y, AGE=1, 
                                  LEN=Linf * (1 - exp(-K * (1 - t0))))
  }
  pop <- append(pop, newR)
}


bdatlist <- sapply(pop, '[', 2)
bdat <- do.call(rbind, bdatlist)

mla <- tapply(bdat$LEN, list(bdat$AGE, bdat$YEAR), FUN=mean)
mla <- mla[,c(5, 25, 50)]
ages <- 1:dim(mla)[1]
matplot(ages, mla, type='o')


