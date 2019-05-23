
# Model parameter files

## set_om_parameters_global.R

* **stockEcxlude**. By default all stocks parameter files listed in the **modelParameters/stockParameters** directory are included in a multi-stock run. If you wish to exclude one or more stocks you can indicate this in the **stockExclude** vector. A value of **NULL** (i.e., ```stockExclude <- NULL```) means that all listed parameter files will be included. To exclude Georges Bank haddock, for example, write ```stockExclude <- 'haddockGB'``` or to exclude both Georges cod and haddock write ```stockExclude <- c('haddockGB', 'codGB')```. Note that file extensions are not included here. The program sets the skip in **runSetup.R**.





## Individual stock parameter files (e.g., codGB.R)

* **stockName**. The name of the stock. For naming use only -- doesn't need to match anything special.

* **burnFmsyScalar**. The scalar for F<sub>MSY</sub> during the burn-in period. This governs the extent to which the fishery is exploited during the burn-in period.

* **burnFsd**. Lognormal standard deviations for *F* during the burn-in period.

* **fage**. First age in the model. Note that changing this parameter also requires a change in the stock recruitment function so that a different age of entry is assumed.

* **laa_par**. Length-at-age parameters. To ensure the parameter names match the required values check the function get_lengthAtAge.

* **laa_typ**. Type of model to use for length-at-age. Check the function get_lengthAtAge for options.

* **waa_par**. Weight-at-age parameters. To ensure the parameter names match the required values check the function get_weightAtAge.

* **waa_typ**. Type of model to use for length-at-age. Check the function get_weightAtAge for options.

* **mat_par**. Maturity-at-age parameters. To ensure the parameter names match the required values check the function get_maturity.

* **mat_typ**. Type of model to use for length-at-age. Check the function get_maturity for options.

* **M**. Natural mortality. So far testing has only included a single value that applies to all ages.

* **qC**. Catchability for the commercial fishery

* **qI**. Catchability for the survey index

* **selC**. Selectivity parameters for the commercial fishery. See function ```get_slx()``` for information on parameters.

* **selcC_typ**. Type of selectivity function. See function ```get_slx()``` for information on types.

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

    * **selI**. Survey selectivity. See function ```get_slx()``` for selectivity options.

    * **selI_typ**. Function type for survey selectivity.  See function ```get_slx()``` for selectivity options.

    * **timeI**. Timing for survey as a proportion of the year (i.e., 0.5 would be a June survey).

    * **ncaayear**. Number of years in the catch-at-age assessment model.

    * **boundRgLev**. Expansion range for setting limits on parameter bounds. For example, if this is set at 1.5 then the parameter bound ranges that are input into the stock assessment model would be 1.5 times the actual value (accounting for the fact that some variables cannot be negative).

    * **startCV**. CV for developing random starting values to use in the assessment model.

    * **caaInScalar**. Scalar necessary to bring numbers in the stock assessment model down so they are more in line with other parameters.
