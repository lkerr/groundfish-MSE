library("Rcpp")

library("microbenchmark")

setwd("/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/scratch/econscratch")
# isOddR <- function(num = 10L) {
#   result <- (num %% 2L == 1L)
#   return(result)
# }
# isOddR(23L)
# 
# cppFunction("
# bool isOddCpp(int num = 10) {
# bool result = (num % 2 == 1);
# return result;
# }")
# isOddCpp(42L)

#Rcpp::sourceCpp("convolve.cpp")

Rcpp::sourceCpp("matsums.cpp")

# data setup
set.seed(92136)
n <- 1000000 
m<- 100
A <- matrix(rnorm(n*m), nrow=n, ncol=m)

#make sure these get the same results
b<-rowSums(A)
sugar<-Sugar_rowSums(A)
armadillo<-Arma_rowSums(A)

all.equal(b,sugar)
all.equal(b,armadillo)


# benchmark 
microbenchmark("BASE" = rowSums(A), "Sugar"= Sugar_rowSums(A),  "Armadillo" =Arma_rowSums(A), times=10)





