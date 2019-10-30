

# Economic module documentation
### Min-Yang Lee; Anna Birkenbach (Min-Yang.Lee@noaa.gov; abirken@udel.edu)

<br> Describes the code that implements the "Economic Simulation Module" in the management strategy evaluation

***
### Status
The code runs and integrates with the stock dynamics models by computing an "F" 

## Overview
The runSim.R file has been modified to allow for an economic model of harvesting to substitute for a standardFisheries model of implementation error.  The economic module can be viewed as an alternative to the get_implementationF() function in a the standard fisheries model.  It takes inputs from the stock dynamics models and outputs an F_full.  It also constructs some economic metrics, but I haven't coded where to save them yet.


## Statistics Behind the Economic simulation module
The population of vessels in the statistical model is: "Vessels that landed groundfish in the 2004-2015 time period, primarily used gillnet or trawl to catch groundfish, elected to fish in the sector program in 2010-2015, and were not falsifying their catch or sales records."  $i$ indexes individuals, $n$ indexes target, and $t$ indexes time (days).

The statistical economic module has two stages. In the first stage, we estimate a Schaefer's harvest equation   
	\begin{equation}
	H_{nit}=h(q_{ni},E_{nit},{X_{it})
	\end{equation}
This is estimated equation-by-equation with ordinary least squares, using a log-log functional form.
	\begin{equation}
	log H_{nit}= log q + b logE + clog X + e
	\end{equation}
although there are more than just these 3 explanatory variables.

Catchability $q$ varies by vessel-target.  The results are used to predict expected harvest of target $n$. These are then adjusted to account for the jointness in catching fish. For example, a trip that is targeting GB cod and that lands 1000 lbs of GB cod is also likely to land 500 lb of GB haddock, 200 lb of pollock, and 80 lb of skates.  We track all these individually and multiply by expected prices to construct expected revenue for vessel $i$'s trip that targets GB cod on day $t$. We repeat for all $i$,$n$, $t$ to construct expected revenue for all feasible choices.  Some of these things also have quota costs -- we subtract quota costs from the expected revenue.

In the second stage, we estimate the probability that a vessel will target "thing" t: 
\begin{equation}
P[Target_{nit}] =P(Revenues_{nit}, Costs_{nit}, Z_{nit})
\end{equation}
We observe whether the vessel actually targeted a thing or did not. These statistical models are referred to as discrete-, binary-, or multinomial- choice models.  The theoretical model underneath this is a Random Utility Model.  Currently, we're using an Alternative-specific Conditional Logit, but we're exploring other options, including nested and mixed logits. Estimation of the asc logit is by maximum likelihood (or quasi-ML, can't remember).

We can simulate either the production or targeting equations at any values of the explanatory variables: for example changes in the trawl survey (used as a biomass proxy) can affect changes in harvest, which feeds into expected revenue and eventually the target equation.  Changes in costs or weather would directly affect the targeting equation. 

We can also simulate what happens when a fishery (GOM Cod, Pollock, Skates) are closed -- how does fishing effort redistribute to other targets?

McFadden,  D.  L.  1974.  Conditional  logit  analysis  of  qualitative  choice  behavior.  In Frontiers  in  Econometrics,  ed.P.  Zarembka,  105–142.  New  York:  Academic  Press

For both the production and targeting models, the unit of observation is a hullnum-day.

The statistical estimation of the model takes place externally to the MSE model -- there isn't a need to have this occur simultaneously (yet).


## The R code
There's a pile of code.

* **runEcon_module.R :**  is a *working* economic module. The last part is kinda janky, but should just about close the bio$\rightarrow$ econ $\rightarrow$ bio loop.  This used to be in the scratch folder with a different name.

* **runEcon_module_counterfactual.R :**  is a *working* economic module.  It has been revised a bit in preparation to run the counterfactual simulations (2010-2015 as-if Days-at-Sea).  But a few details need to be ironed out, because it has only been prototyped using post-as-post (2010-2015 as-if catch shares) data.
  
 #. POSTasPRE is the counterfactual.  It uses pre-multipliers, pre-production, but post-prices
 #. POSTasPOST is the validation.  It uses pst-multipliers, post-production, post prices. It uses Pre coefficients. 



* **runSim_Econ_counterfactual.R :**  is a modified version of runSim.R. This should only need minor changes (setting parameters) before it is finalized.

* **loadsetRNG.R :**  code to load/reset the RNG state based on a list.

* **speedups_econ_module2.R :**  code for benchmarking the economic model.
 
There are  "processes" files that run one time per simulation run: 
* **genBaselineACLs.R:** This is used to construct "baseline" ACLs for the non-modeled stocks. That includes Groundfish *and* non-groundfish stocks like lobster or skate that either caught with groundfish or altenatives to taking a groundfish trip.

* **genEcon_Containers.R:** Gets called in the runSetup.R file. It sets up a few placeholders for Fleet level economic outputs.

* **loadEcon.R:** Gets called in the runSetup.R file. Loads in some of the smaller data.tables that will remain in memory every time runSim.R is called.

* **loadEcon2.R:** Gets called in the runSim.R file.  Loads in a single large data.table that remains in memory for one simulated year.  These files are too big to load and hold in memory for the entire simulation.  

Functions - these run many times per simulation:
* **get_bio_for_econ:** passes *things* from the biological model (in stock[[i]]) to the economic model.

* **get_fishery_next_period:** adds up catch from individual vessels to the daily level and then aggregates with prior catch.  Checks if the sector sub-ACL is reached and closes the fishery if so.
* **get_fishery_next_period_areaclose:** adds up catch from individual vessels to the daily level and then aggregates with prior catch.  Checks if the sector sub-ACL is reached and closes the fishery if so.  For the allocated multispecie stocks, this creates and extrac column that indicates if that stockarea is closed.

* **get_joint_production:** Replaces the catch multiplier, landings multiplier, quota prices, lag prices, and prices with catch (lbs), landings(lbs), quota prices, lag prices, and prices.  This accounts for the jointness in production. These variables are now a little misleading in names.  However, I chose to replace instead of create new columns to save on space.

* **predict_eproduction:** Predicts harvest of the target species, returns a data.table

* **predict_etargeting:** predicts targeting, returns a data.table.

* **get_random_draw_tripsDT:** for each vessel-day (id) randomly selects a choice (spstock2) based on prhat. Reworked to  data.table

* **get_reshape_catches:** Aggregates the catch from the day's trips to the fleet level.

* **get_reshape_landings:** Aggregates the landings from the day's trips to the fleet level.

* **joint_adjust_allocated_mults:** Adjusts the joint production multipliers for the allocated multispecies stocks
* **joint_adjust_others:** Adjusts the joint production multipliers for other stocks


* **zero_out_closed_areas_asc_cutout:** Closes a fishery and redistributes the probability associated with that stock to the other options.  This is based on the "stockarea_open" logical column.   Skips math if all stocks are open


* **get_reshape_targets_revenues:** A small "helper" function to reshape targets and revenues.

There are few files in "scratch/econscratch" that may be useful
* **test_predict_etargeting_and_production.R :** was used to verify that the predict_etargeting.R and predict_eproduction.R functions works properly. It runs as a standalone and might be fun to explore. 

* **test_econ_module.R :**  is a test economic module. The last part is incredibly janky, but should just about close the bio$\rightarrow$ econ $\rightarrow$ bio loop. I'm just waiting to have runSim.R reordered before I can use it to write out F_full to stock[[i]] for the modeled stocks.  Pieces of this will be put into fragments that are called by "runSetup.R" (perhaps with an if cut-out for EconomicModel) because they only need to be run once.  Other parts should be converted into a function or many functions.

Obsolete
These are obsolete and have been moved to /scratch/econscratch/obsolete
* **get_at_age_stats, get_catch_at_age, get_e_smear, test_get_at_age_stats, test_get_catch_at_age, test_predict_eproduction:** all probably are obsolete and have been moved to /scratch/econscratch/obsolete.
* **get_random_draw_trips:** for each vessel-day (id) randomly selects a choice (spstock2) based on prhat
There are a few files in "/preprocessing/economic/"  These primarily deal with converting data from stata format to RData and making the estimated coefficients "line up" with the data.  There is also a helper file to wrangle the historical catch limit and catch data.   
* **zero_out_closed_asc:** Closes a fishery and redistributes the probability associated with that stock to the other options.
* **speed_asclogit:** Speed testing for an asc logit.

* **predict_eproductionCpp:** A version that uses RCpp sugar. This wasn't faster than base R.  I think this is because each "day" is a relatively small dataset.  Predicts harvest of the target species, returns a data.table

* **predict_etargetingCpp:** A version that uses RCpp sugar. This wasn't faster than base R.  Predicts targeting, returns a data.table.

* **get_best_trip:** for each vessel-day (id) selects the choice (spstock2) with the highest prhat. Obsolete and should be removed.

* **zero_out_closed_asc_cutout:** Closes a fishery and redistributes the probability associated with that stock to the other options. This is based on the "underACL" logical column.   Skips math if all stocks are open.  This is obsolete because the underACL logical is always equal to the stockarea_open, regardless of how we are modeling closures.

## Pre-processing
A bunch of pre-processing is needed to go from the stata econometric output to R data.tables.  Some of this is written in Stata .do files.  The rest is written as R batch files.  


* **wrapper.do** This is a wrapper to run all the stata .do files. You'll need to change the projectdir global. You may need to change the file names themselves.  There are versions of this for settin counterfactual data (wrapper_CF.do) and validation data (wrapper_validation.do).  All of the wrappers run the stata code --you may want to change a few global macros that define which files are which. 


* **asclogit_coef_export.do** This exports the stata estimates to csv.
* **stocks_in_model.do** This makes a 1 column dataset of spstock2.  
* **recode_catch_limits.do** A little cleanup and conforming of the catch limit csv.
* **price_prep.do** : Construct output prices at the spstock2-date level and input prices at the hullnum-spstock2-date level.  Note -- right now, we are only have Post period prices ready. All simulations are currently using 2010-2015 prices.  This may break things

* **pre_process_econ.R:** This is a wrapper to  run *all* of the R and stata code. You will need to change paths to directories, you may need to change some filenames.  We set all the input and output filenames here.  This has been tested to work on a "data_for_mse" dataset.

* **pre_process_AB_counterfactual.R:** This is a wrapper to  run *all* of the R and stata code to set data up for "counterfactual simulations".  You will need to change paths to directories, you may need to change some filenames.  We set all the input and output filenames here.  This has been tested to work on a "POSTasPRE" dataset.  

* **pre_process_AB_validation.R:** This is a wrapper to  run *all* of the R and stata code to set data up for "counterfactual simulations".  You will need to change paths to directories, you may need to change some filenames.  We set all the input and output filenames here.  This has been tested to work on a "POSTasPOST" dataset.




* **targeting_coeff_import.R** converts the results of asclogit_coef_export to an R data.table
* **production_coefs.R** imports the targeting regression coefficients to an R data.table
* **price_import.R** imports and save sdata.tables containing  prices
* **multiplier_import.R** constructs vessel 
* **vessel_specific_prices.R** imports and saves data.tables containing vessel level prices
* **targeting_data_import.R** constructs the simulation datasets.  There are the "data" is joined to coefficients, prices, and multipliers using various combinations of "hullnum", "MONTH" , "spstock2", "doffy" (day of groundfish fishing year), "gearcat".  Note that because the data loops through "gffishingyears", we we do not join on gffishingyear. This piece of code also computes average multipliers in the pre-period for the counterfactual sims.



## Input Data
There are a few input datasets needed to run. 
* **full_targeting_YYYY.Rds** - contains "independant variables" associated with the production and targeting models, estimated coefficients. Each row corresponds a vessel-day-targeting choice.  I tried to optimize for less memory usage, but it makes the model run extremely slowly.  

* **sim_post_vessel_stock_prices.Rds** vessel-day level input prices. fuelprice and crew wages vary by vessel.  This variability is partially due to their locations (prices of fuel vary by state; so do prices of labor). Also varies based on the size and composition of the boat's crew.

* **sim_prices_post.Rds**  day-level output prices that are gearcat specific. They are gearcat specific because the mix  of "other" varies by gearcat.

* **sim_multipliers_pre.Rds**  These are vessel specific coefficients that scale landings of a target species to catch/landings of other (non-target) species that are used for simulating the pre catch-share period.

* **sim_multipliers_post.Rds**  These are vessel specific coefficients that scale landings of a target species to catch/landings of other (non-target) species that are used for simulating the post catch-share period.

I've been making small changes to mproc_test.txt and the "set_om_parameters_global.R" file.  The set_om_parameters_global.R contains things like file/folder locations, stocks that are in the model, and the RHS variables for the simulations.

### Outputs
Model outputs are TBD


### To do and known bugs
* needs to do state dependence properly.

* **runEcon_module.R :** 
  * Needs to be cleaned up.  Uses about 7-8gb.
  * Needs to be sped up.
    * The tidyverse version took approx 48sec/yr.
    * The revised data.table version takes 19 seconds/yr (depending on how often fisheries are closed). I should probably profile the code to speed it up.
    * I tried rewriting the model to economize on memory by only loading "small" data.tables and then mergeing them. That actually takes a large amount of time (>2-3 minutes). 
  * Doesn't read/use IJ1 trawl survey index(biomass index computed on Jan 1).
  * does not store fishery revenue anywhere, just overwrites it.
  * slowest parts are joint_production, zero-ing out the closed stocks, and the randomdraw.
  
### Notes
* packages are gmm, mvtnorm, tmvtnorm, expm, msm, Matrix, TMB, forcats, readr, tidyverse, dplyr, data.table
* the targeting and production datasets now conform. Production dataset is not necessary.

 * The Econ module is mostly written using data.table. 
 

[Return to Wiki Home](https://github.com/thefaylab/groundfish-MSE/wiki)
