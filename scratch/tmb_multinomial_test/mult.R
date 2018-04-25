


# load the TMB package
require(TMB)


# compile the c++ file and make available to R
compile('scratch/tmb_multinomial_test/mult.cpp')
dyn.load(dynlib("scratch/tmb_multinomial_test/mult"))

p <- c(1,3,5,4,2,7,9,7,9,5)
p <- p / sum(p)


data <- list(
             x = 1:10,
             p = p
)



parameters <- list(
                   dummy = 1
)








# make an objective function using the data, the
# parameters and referencing the compiled c++
# code.  This model has random effects so include
# the "random" argument.
obj <- MakeADFun(data = data,
                 parameters = parameters,
                 DLL = "mult")



# run the model using the R function nlminb()
opt <- nlminb(start=obj$par, 
              objective=obj$fn, 
              gradient=obj$gr)

# estimates and standard errors (run after model optimization)
sdrep <- sdreport(obj)

# list of variables exported using REPORT() function in c++ code
rep <- obj$report()

-dmultinom(x=data$x / sum(data$x) * 50, p=data$p, log=TRUE)

xp <- data$x / sum(data$x)
dmultinom(x=xp, size=54, p=data$p, log=TRUE)



# Testing the dmultinom function in R

# set of xs, ps and ns. Default n is the sum of the 
# x vector
x <- 1:3
p <- c(8, 4, 3)
p <- p / sum(p)
n <- sum(x)

# writing out the equation versus using the
# dmultinom function
log(factorial(n) / prod(factorial(x)) * prod(p^x))
dmultinom(x=x, p=p, log=TRUE)


# how to integrate effective sample size? Looks like it
# works if you just make x into a vector of probabilities
# instead and then multiply it by n. Basically you are just
# scaling the xs by whatever you want the effective sample
# size to be.

n2 <- 75
x2 <- x / sum(x)

-log(factorial(n2) / prod(factorial(x2*n2)) * prod(p^(x2*n2)))
-dmultinom(x=x2*n2, p=p, log=TRUE)

