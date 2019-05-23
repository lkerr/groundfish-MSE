
# Model parameter files

## set_om_parameters_global.R

* **stockEcxlude**. By default all stocks parameter files listed in the **modelParameters/stockParameters** directory are included in a multi-stock run. If you wish to exclude one or more stocks you can indicate this in the **stockExclude** vector. A value of **NULL** (i.e., ```stockExclude <- NULL```) means that all listed parameter files will be included. To exclude Georges Bank haddock, for example, write ```stockExclude <- 'haddockGB'``` or to exclude both Georges cod and haddock write ```stockExclude <- c('haddockGB', 'codGB')```. Note that file extensions are not included here. The program sets the skip in **runSetup.R**.





## Individual stock parameter files (e.g., codGB.R)

* **Recruitment**. Parameters for recruitment functions. Either derived from model fits or when examining potential scenarios / sensitivity runs. Below are listed the parameters that each model requires. Standard deviations for stock recruitment are included separately listed under pe_R in the individual stock parameter files.
  * Traditional Beverton-Holt:
    * a
    * b
    * c -- the temperature effect
    * rho -- any annual AR1 correlation effect
  * Beverton-Holt steepness parameterization. The beta parameters can be left out if not included in the model and they will be converted to 0.
    * R<sub>0</sub> -- virgin recruitment
    * h -- steepness
    * beta1 -- temperature effect on steepness
    * beta2 -- temperature effect on R<sub>0</sub>
    * beta3 -- temperature effect on overall error
    * rho -- any annual AR1 correlation effect
    * SSBRF0 -- spawner biomass per recruit at F=0. Stock assessment results are a good place to look for this. Alternatively could build a per-recruit model and use the M selectivity, maturity, etc. from a recent assessment
