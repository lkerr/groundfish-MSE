

# Integrated catch-at-age model using TMB
### Sam Truesdell (struesdell@gmri.org)

<br> Describes the code that implements the TMB-based catch-at-age model in the management strategy evaluation

***

### What is TMB
Template Model Builder is a program that can be used to estimate parameters of complex nonlinear models. It draws heavily from AD Model Builder (which many integrated assessment models use for parameter estimation). TMB is especially good at dealing with models that include random effects although that functionality is not used here (at this time). What is useful here is that it is also well-integrated with R. More information on TMB can be found on the [TMB GitHub webpage](https://github.com/kaskr/adcomp/wiki).

Just like ADMB, TMB can handle complex nonlinear models because it relies on a compiled program. TMB code in R requires two parts: (1) an R script that drives the model; and (2) a c++ file that is compiled into an executable program. TMB calculates the derivatives of the likelihood function in the c++ code and then feeds that information to one of R's optimizers (e.g., optim() or nlminb()). Since R has the derivatives of the likelihood function estimating the parameters is not complicated.

For the simple case of the assessments for this project the results from the TMB catch-at-age model should be very similar to a version created with ADMB. TMB was used because it is easily integrated with R and for the potential to treat parameters as random effects if desired.


### The CAA c++ code
The c++ code (caa.cpp) specifies the population structure assumed by the model and defines the likelihood function. In the first part of the code, data and parameter starting values and bounds are passed from R and containers that will hold values later on are defined. Next the population dynamics are specified. Third, the negative log likelihood is defined (these are variables that start with NLL in the code). The final section of the code is the Report section. Every variable that is associated with the REPORT() syntax is passed back to R.


### The R code
The R code (caa.R) drives the assessment model.  A few relevant pieces of the code are:

* **map_par:** this variable is a list that defines which parameters will be estimated during the model run. If a parameter is not estimated then the initial value will be used.

* **lb** and **ub:** these lists provide the upper and lower bounds for the parameters in the model. The lists are defined in [processes/get_tmb_setup.R](../processes/get_tmb_setup.R).

* **makeADFun():** a TMB function that creates an objective function for R to use in its optimizer. Part of its output is the function derivative.

* **nlminb():** One of the optimizers in R. optim() could also be used. The objective function and the derivatives are passed to nlminb() so R is able to estimate the parameters in this complex model.

* **sdreport():** A TMB function that estimates the standard errors.


### Inputs
Data, starting values and parameter bounds are all produced in the file [processes/get_tmb_setup.R](../processes/get_tmb_setup.R). Parameter starting values are produced using the function [functions/assessment/get_svNoise.R](../functions/assessment/get_svNoise.R) and bounds produced using the function [functions/assessment/get_bounds.R](../functions/assessment/get_bounds.R).

### Outputs
Model outputs are specified in the c++ file using the REPORT() function and are read into R using obj$report() (where obj is the objective function specified by MakeADFun()).



### Notes
* Notably, in order to run TMB you must have RTools installed on your machine. This is because TMB uses a particular compiler to compile the c++ code. ADMB uses a different compiler. In the past when I have tried to compile TMB models I have run into instances where TMB tried to use my ADMB compiler which causes lots of errors. If you think this may be happening to you, try
```
path0 <- Sys.getenv('PATH')
path1 <-  paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                 path0)
Sys.setenv(PATH=path1)
```
This will update your environmental variables for the current session so that the first compiler TMB will encounter will be the correct one from RTools.

* I had issues compiling on the Linux system when I already had compiled objects transfered over from the Windows system.  Apparently if you have .o and .dll files in the directory then linux can't figure out how to run the compilation because first it is checking to see if you have compiled files or not and if you do it tests them to see if anything has changed ... at any rate something goes a little awry if you have old files in there. Did not test whether this includes both the .o and the .dll or just one of them: I just delete.

[Return to Wiki Home](https://github.com/thefaylab/groundfish-MSE/wiki)
