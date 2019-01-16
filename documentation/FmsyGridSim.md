
Grid searches for Fmsy
------
This document describes the methodology for determining F<sub>MSY</sub> based on maximizing yield over a grid search.


#### Inputs

* Life history information, including:
  * selectivity-at-age
  * maturity-at-age
  * natural mortality-at-age
  * weight-at-age
* Initial numbers-at-age
* Recruitment function (from mproc.txt)
* Number of years to run the simulation (*n*)
* Temperature information (if necessary)
* Candidate values for *F* (a vector running from 0 to 2.0)

#### Operation
The function operates following these steps:
1. Starting with the initial numbers-at-age, run a simple age-structured projection for *n* years [SEE NOTE AT END OF DOC] and use the life history information and the first potential value for F. Recruitment will depend on the entries in mproc.txt for *RFUN_NM* and *FREF_PAR0*. When operating under the *FREF_TYP* FmsySim, which we are here, *FREF_PAR0* refers to a number of years in the forecast or hindcast function. Recruitment options are
  * **hindcastMean**: Recruitment in each year will be an average over a number of recent years. The number is specified by *FREF_PAR0*. For example, if *FREF_PAR0* is 10, recruitment in each year of the projection will be average recruitment over the ten previous years estimated by the stock assessment model (note that recruitment does not change -- the assessment model is not run during this projection).
  * **forecast**: Recruitment is calculated in each year of the projection using the Beverton-Holt stock assessment model, potentially with a temperature effect if that switch is turned on.  For example, in year *y* the recruitment will be<br/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;R<sub>y</sub> = BH(SSB<sub>y</sub>,T<sub>y</sub>)<br/>
  where BH is the Beverton-Holt function, SSB<sub>y</sub> is the spawner biomass in year *y* and T<sub>y</sub> is the temperature in year *y*.

  <br/>At the end of the projection the average yield (in biomass) over all years (save the initial condition year) is recorded.

2. Repeat step 1 for each candidate value of F and save corresponding average yield

3. Find the maximum average yield over the grid of Fs that were tested.  The F associated with the maximum yield is F<sub>MSY</sub>.


#### Outputs
The estimated value for F<sub>MSY</sub>.

##### Note:
The way the simulation is coded right now, the number of years in the projection is the same as the number of years that the recruitment function uses in the simulation. For example, if n=10:
  * The *hindcastMean* recruitment function will use the mean of the last 10 years in the assessment model as recruitment in each year of this projection
  * The *forecast* recruitment function will run the projection 10 years forward (including temperature information)
  * In **both** cases the projection will be run for **only** 10 years. The reason for this is that the *forecast* recruitment function is linked to actual temperature projections beyond the current year. Accordingly it does not make sense to run the projection for, say, 1000 years because no such projections are available. *hindcastMean* could be run for 1000 years but it is not set up that way so that it mirrors the process in the *forecast* recruitment function.

The way this is currently set up the initial conditions have too much influence over the calculated F<sub>MSY</sub>. A possible solution is to change the initial values. If the initial values were in equilibrium given the current temperature (in the case of using *forecast*) or recruitment mean assumption (in the case of *hindcastMean*) then it might work to only run for 5 or 10 years.
