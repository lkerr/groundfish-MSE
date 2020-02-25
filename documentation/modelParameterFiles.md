
# Model parameter files

## Overall MSE parameters: set_om_parameters_global.R

* **simpleTemperature**. T/F. If true then the temperature data are smoothed. This can be used for debugging because it is nice when you can know that the temperature is supposed to be increasing in every single year.

* **mprocTest**. T/F. If true then **mproc.csv** is bypassed in favor of **mprocTest.csv**. **mprocTest** holds a variety of test cases for the management procedures that is meant to span the range of the potential options. The idea is that if you can run the code using **mprocTest** without errors cropping up then you are probably good to go. Feel free to add to this file to increase its utility; definitely add to this file if you make a substantive change to the management procedure options.

* **stockEcxlude**. By default all stocks parameter files listed in the **modelParameters/stockParameters** directory are included in a multi-stock run. If you wish to exclude one or more stocks you can indicate this in the **stockExclude** vector. A value of **NULL** (i.e., ```stockExclude <- NULL```) means that all listed parameter files will be included. To exclude Georges Bank haddock, for example, write ```stockExclude <- 'haddockGB'``` or to exclude both Georges cod and haddock write ```stockExclude <- c('haddockGB', 'codGB')```. Note that file extensions are not included here. The program sets the skip in **runSetup.R**.

* **nrep**. Number of times to repeat the analysis. On a local machine should be the number of times to repeat the simulation (i.e., how many independent iterations do you want?). For an hpcc run the total repetitions will be nrep multiplied by the number of repetitions given in **runSim.sh**. For HPCC runs **nrep** can usually be set to 1. There is an interaction with the number of management procedures specified in the **mproc** file, but typically more than 5 or so repetitions on a Windows machine will cause R to crash. No such problems on Linux machines.

* **fmyear**. First management year. In other words. In what actual year (like year 2000, not an index) should the management procedure kick in?

* **fyear**. The first year following the initial condition period (being the period even before the burn-in). This period exists because the stock-recruit function refers back *fage* number of years. During this period the matrices necessary to build up the stock-recruit function are filled up with constant values. The burn-in period should be long enough that these values should not matter at all. Code could probably be slicker if this parameter was removed and *fage* was used directly.

* **mxyear**. The maximum year to predict into the future (you don't necessarily have to go all the way to the end of the temperature projection series).

* **nburn**. The number of true burn-in years before any temperature time series is picked up. If the temperature series starts in 1900 nburn will be the number of years prior to 1900 that should be included. These years will use an average temperature value from an early portion of the time series.

* **useTemp**. T/F. If true then the temperature time series is used. If false than an average temperature from the pre-climate change period is used for the entire simulation. Turn this off to examine the effects of MPs assuming stable population dynamics.

* **cmip5model**. The name of the cmip5 model data set to use. If the cmip5 data column is called 'CMCC_CM' then assign this to the value of *cmip5model*. Hybrid / alternative temperature models can be created by adding columns to the cmip5 data set and referring to them here by name.

* **ref0** and **ref1**. Reference years for temperature downscale. The downscaling procedure will use these reference years in the CMIP5 data series and in the Georges Bank temperature series in order to standardize the CMIP5 projections into the future onto the scale of Georges Bank.

* **baseTempYear**. During the burn-in period and prior to linking with the temperature hindcasts temperature is constant. The constant temperature is defined by anomFun(T<sub>y<bty</sub>) where anomFun is the anomaly function (e.g., mean or median), T stands for temperature and y stands for year. So temperature during the burn in period is going to be a function of all temperatures in the temperature data set prior to *baseTempYear*.

* **anomFun**. See description of *baseTempYear*. This is the reducing function that sets the temperature during the burn-in period before linking with the temperature hindcast.

* **BrefScalar** and **FrefScalar**. MSY-based biomass and fishing mortality reference points are often not used directly. For example, instead of the threshold for action in US fisheries being B<sub>MSY</sub> it is instead 1/2B<sub>MSY</sub>. So if you want the implemented B<sub>MSY</sub> reference point to be 1/2B<sub>MSY</sub> set this to 0.5. Same for fishing mortality -- if you want implemented fishing mortality to be 3/4F<sub>MSY</sub> set this to 0.75.

* **plotBrkYrs**. Performance metric plots are not necessarily generated using all data at once. Instead they are divided into periods. This is especially useful under temperature scenarios -- early periods do not have as much temperature change so the impacts of some management strategies will not be as great. *plotBrkYrs* should be a vector of breaks. If it is ```c(5, 10, 20)``` the resulting performance measure boxplots will be divided into years 5-10, years 11-20 and years 21 to the end of the time series. 



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

* **oe_sumCW**. Observation error for total catch in weight.

* **oe_sumCW_typ**. Type of observation error for catch in weight.

* **oe_paaCN**. Observation error for proportion-at-age samples from the catch in numbers.

* **oe_paaCN_typ**. Type of observation error for proportion-at-age samples from the catch in numbers.

* **oe_sumIN**. Observation error for survey index in numbers.

* **oe_sumIN_typ**. Type of observation error for survey index in numbers.

* **oe_paaIN**. Observation error for proportion-at-age samples in numbers from the survey index.

* **oe_paaIN_typ**. Type of observation error for survey index proportion-at-age samples in numbers.

* **oe_effort**. Observation error for fishing effort.

* **oe_effort_typ**. Type of observation error for fishing effort.

* **pe_R**. Recruitement process error (lognormally distributed)

* **ob_sumCW**. Observation error bias for fishery catch in weight. 1.0 is no bias, 0.9 is -10% bias, 1.1 is +10% bias etc.

* **ob_sumCW**. Observation error bias for fishery catch in weight. 1.0 is no bias, 0.9 is -10% bias, 1.1 is +10% bias etc.
