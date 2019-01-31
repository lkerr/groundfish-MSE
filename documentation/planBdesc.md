
# Bare-bones description of Chris Legault's PlanBsmooth code
#### (Sam Truesdell struesdell@gmri.org)

## More information
As stated in the title, this is a barebones documentation file created by someone other than the author of the ApplyPlanBsmooth.R code (i.e., Chris Legault). The actual code for the function ApplyPlanBsmooth can be found here: [groundfish-MSE/functions/assessment/apply_PlanBsmooth.R](../functions/assessment/apply_PlanBsmooth.R). This is my attempt at an overview.


## Official documentation file
Chris Legault's documentation reads:  
> Organizes data from either user supplied csv file or ADIOS! survey file. Allows standardization and selection of surveys to use. Creates an average biomass index and applied loess smooth. Log linear regression used for most recent three years to estimate multiplier for setting catch advice in next year.

## Data
The data for the plan B smooth function are a time series that includes years and biomass index data (i.e., from a survey). Catch data are required for actual advice but that step occurs outside of the apply_PlanBsmooth() function.

## Steps
The steps below include R-based pseudocode just to make the explanations easier. The assignments and functions used aren't actually the same as in apply_PlanBsmooth(). The steps for calculating a multiplier are:

1. Apply a loess smoother to **biomass** index data over the entire time series. Something like:
```
lfit <- loess(bioInd ~ yrs)
pred_fit <- predict(lfit)
```  
where ```bioInd``` is the biomass index from a survey, ```yrs``` are the corresponding years for the index,  ```loess()``` is the smoothing function, and ```pred_fit``` are the fitted values (i.e., predictions) for every year.

2. Extract the  last three  values from the model predictions
```
yrs2use <- tail(yrs, 3)
pred2use <- tail(pred_fit, 3)
```
where ```yrs2use``` represents the final three years in the time series and ```pred2use``` represents the final three loess predictions.

3. Fit a model of the logged last three values against year:  
```
planBlm <- lm(log(pred2use) ~ yrs2use)
```
4. Extract the slope from the model and return it to the arithmetic scale.
```
slp <- coef(planBlm)[2]
mult <- exp(slp)
```
where ```slp``` is the slope and ```mult``` is the multiplier that is output by the function.

This is the end of the planB code -- it just produces the multiplier. In order to generate catch advice the multiplier should be applied to some function of the catch time series (e.g., catch in the last year, average catch over the last three years, etc.)

[Return to Wiki Home](https://github.com/thefaylab/groundfish-MSE/wiki)
