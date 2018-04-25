


theta <- function(alpha0, alpha1, alpha2, age){
  x <- alpha0 / (1 + exp(alpha1 * (alpha2 - age)))
  plot(x ~ age, ylim=c(-1, 1))
  abline(h=c(-1, 0, 1), lty=c(2,1,2))
}


ages <- 0:12

theta(alpha0=1, alpha1=-5, alpha2=6, ages)

theta(alpha0=-1, alpha1=0.7, alpha2=6, ages)

theta(alpha0=-1, alpha1=-0.7, alpha2=6, ages)

theta(alpha0=exp(rep$alpha0), alpha1=exp(rep$alpha1), 
      alpha2=5, ages)



