
# Model parameter files

## set_om_parameters_global.R

* **stockEcxlude**. By default all stocks parameter files listed in the **modelParameters/stockParameters** directory are included in a multi-stock run. If you wish to exclude one or more stocks you can indicate this in the **stockExclude** vector. A value of **NULL** (i.e., ```stockExclude <- NULL```) means that all listed parameter files will be included. To exclude Georges Bank haddock, for example, write ```stockExclude <- 'haddockGB'``` or to exclude both Georges cod and haddock write ```stockExclude <- c('haddockGB', 'codGB')```. Note that file extensions are not included here. The program sets the skip in **runSetup.R**.
