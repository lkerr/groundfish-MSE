

# example of age length key
# 
# Develop age and length data set using von Bertalanffy function
# as well as a second group of lengths that are based on the ages
# but have different errors.  The first group of lengths will be
# used in the age-length key development and the second group in
# the testing.
# 
# Once you get the data, build the age-length key, and then take in
# a new data set of lengths and get estimated ages from there.




#load in the functions
source('preprocessing/recruitment/functions/get_alk.R')
source('preprocessing/recruitment/functions/get_ages.R')


# Simulate age data
sage <- round(runif(300, 1, 20))

# Simulate length data (using vonB). One set for ALK development
# and another set for testing
slen <- 200 * (1 - exp(-0.25 * sage)) + rnorm(300, 0, 15)
slen2 <- 200 * (1 - exp(-0.25 * sage)) + rnorm(300, 0, 15)




# get the age-length key
# age and length matrix
smat <- matrix(c(sage, slen), ncol=2)
salk <- get_alk(almat=smat, lint=10, roundBase = 10)

# get the ages (first based on the data that were used to
# generate the ALK and second for the new set of data)
eage <- get_ages(alk=salk, lengths=slen, vector=TRUE)
eage2 <- get_ages(alk=salk, lengths=slen2, vector=TRUE)


# Visualize the test using density plots. The density of the
# sample ages and estimated ages based on the sample lengths
# should overlap completely while the density of the new length
# data set should be a little different but in the same neighborhood.
dsage <- density(sage)
deage <- density(eage)
deage2 <- density(eage2)

rg <- range(dsage$y, deage$y, deage2$y)
plot(density(sage), lwd=10, col='gray', ylim=rg)
lines(density(eage), lwd=2, col='blue')
lines(density(eage2), lwd=2, col='red')

