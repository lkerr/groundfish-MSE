


# Options for management procedures
### (What to write in the mproc.txt file and what it means)


## ASSESSCLASS
Refers to the class of assessment model. Options are:

* **CAA**: A catch-at-age model. Currently written in TMB but planning additional option for ASAP-based version.

* **PLANB**: Index-based approach. This version uses Chris Legault's apply_PlanBsmooth() function. More information on that can be found here: [groundfish-MSE/documentation/planBdesc.md](documentation/planBdesc.md).

## HCR
Refers to the shape of the harvest control rule. Options are:

* **constF**: The harvest control rule is simply a flat line, in other words no matter what in each year F will be determined by the F reference point.

* **simplethresh**: A simple threshold model. If the estimated SSB is larger than the SSB reference point then the advice will be fishing at the F reference point. If the estimated SSB is smaller than the SSB reference point F will be 0.

* **slide**: A sliding control rule.  Similer to simplethresh, except when the estimated SSB is lower than the SSB reference point fishing is reduced though not all the way to zero. Instead, a line is drawn between [SSBRefPoint, FRefPoint] and [0, 0] and the advice is the value for F on that line at the corresponding estimate of SSB.

* **NA**: A possible value for situations where there is no harvest control rule (e.g., if using a planB assessment method -- that method gives catch advice directly).


## FREF_TYP
Refers to the method for developing the F reference point (i.e., a proxy for F<sub>MSY</sub>).  Options are:

* **YPR**: Use yield-per-recruit methods to develop the F<sub>MSY</sub> proxy. Yield-per-recruit provides an F estimate that maximizes yield given growth rate, a selectivity pattern and natural mortality-at-age. Assumes constant recruitment.

* **SPR**: Use spawning potential ratio methods to develop the F<sub>MSY</sub> proxy. Spawning potential ratio depends on estimates of spawner biomass-per-recruit models. Those models assume natural mortality, growth and maturity schedules to determine the level of fishing mortality that results in a given level of average spawner biomass-per-recruit. Spawning potential ratio models take the levels of spawner biomass-per-recruit and standardize them to the maximum (i.e., the level at F=0).  This way the reference points that are developed are comparable among stocks that have different life histories. Spawning potential ratio matches a level of fishing mortality with a given ratio of spawner biomass-per-recruit at that level of fishing mortality relative to spawner biomass-per-recruit at zero fishing.

* **Fmed**: ICES approach that translates average recruitment-per-spawner to a value on the spawner biomass-per-recruit curve to determine the F<sub>MSY</sub> proxy reference point. This approach has not worked particularly well so far because mean recruitment is so variable. Fmed does not require additional parameters (i.e., FREF_PAR0 should be set to NA).

* **FmsySim**: Use simulation to determine F<sub>MSY</sub>; in other words try a set of candidate values for F, run a projection, and at the end of that process determine which value for F maximized yield.

* **NA**: A possible value for situations where there is no harvest control rule (e.g., if using a planB assessment method -- that method gives catch advice directly).

## FREF_PAR0
Refers to the parameters necessary for developing the F<sub>MSY</sub> proxy. These are presented here as linked to the reference point types above.

* **YPR**: The value that represents *x* percent of the slope at the origin. Definitely the most common entry here will be 0.1 (for 10%), which will give the reference point F<sub>0.1</sub>. You have thought pretty hard about this if you are using something other than 0.1 here).

* **SPR**: The value representing the desired quotient of spawning biomass-per-recruit at the reference point to spawning biomass-per-recruit at zero fishing. A value of 0.4 (corresponding to F<sub>40%</sub>) would indicate that F should be set at a level that represents 40% survival relative to F=0.

* **Fmed**: Fmed does not require additional parameters so FREF_PARO should be set to NA.

* **FmsySim**: The parameter value if using FmsySim is related to how recruitment should be treated. If the recruitment function is *hindcastMean* this will represent how many years to look back into the past for this calculation. For example, if the value is set to 10, recruitment in each year of the projection that is used to generate F<sub>MSY</sub> will be the average of the (assessment model-estimated) previous 10 years of recruitment. If the recruitment function is *forecast*, this parameter represents the number of years to look into the future when running the simulation. Each year in the future will use the projected recruitment for that year (including temperature effects if they are switched on).

* **NA**: A possible value for situations where there is no harvest control rule (e.g., planB) or the reference point does not require a parameter (e.g., F<sub>MED</sub>).


## BREF_TYP
Methods for determining the SSB<sub>MSY</sub> proxy.

* **RSSBR**: SSB<sub>MSY</sub> will be the level of spawning biomass-per-recruit at the F<sub>MSY</sub> proxy multiplied by "average" recruitment. Average recruitment is determined by the values provided under *RFUN_NM* and *BREF_PAR0*. Only the *hindcastMean* option is available with this reference point method because forward-looking methods to derive recruitment (that depend on temperature) would also imply using forward-looking methods for spawner biomass which RSSBR does not do.

* **SIM**: SSB<sub>MSY</sub>  developed via simulation. Projections are carried forward for *n* years (which is indicated in BREF_PAR0) and at the end of that period the mean SSB will be used as the SSB<sub>MSY</sub> proxy.  If *forecast* is used as the recruitment function then temperature will be included in the projections (if it is switched on).

* **NA**: A possible value for situations where there is no harvest control rule (e.g., planB).


## BREF_PAR0
Refers to the parameters necessary for developing the B<sub>MSY</sub> proxy. These are presented here as linked to the reference point types above.

* **RSSBR**: The value entered is the number of years to look back in a hindcast recruitment function. For example, if the value is 10 the average recruitment that will be used would be the average (assessment model-estimated) recruitment over the previous 10 years.

* **SIM**: This parameter has options depending on the type of recruitment function that is used. If the *hindcastMean* recruitment function is used then it represents the number of years over which the average is calculated (see example in previous entry for RSSBR). If the *forecast* recruitment function is specified the parameter represents the number of years that will be averaged over in the forecast simulation (which involves temperature if that functionality is switched on).

* **NA**: A possible value for situations where there is no harvest control rule (e.g., planB).


## RFUN_NM
The type of recruitment function to be used. Currently all options involve Beverton-Holt curves but this is easily expanded if desired.

* **forecast**: Recruitment in any simulations for the development of F<sub>MSY</sub> or B<sub>MSY</sub> reference points will be calculated based on a forecast. In each year of the simulation, expected recruitment will be calculated (with a temperature effect if that switch is turned on). At the end of the *n*-year projection period (where *n* is specified under FREF_PAR0 or BREF_PAR0) the value for the F or B reference points is calculated according to the specifications given under those columns in *mproc.txt*.

* **hindcastMean**: Recruitment in each year of a simulation is based on a set of previous recruitments (recruitment values are outputs from assessment models). The function simply returns the mean recruitment over the number of years specified under the parameterization in FREF_PAR0 or BREF_PAR0.


## RPINT
The frequency with which reference points are re-calculated.

* The value represents the frequency. For example, if the value is 3, reference points are recalculated every 3 years. In the years when the reference points are not updated the advice may change based on an updated assessment model but the reference points (and thus the shape of any associated harvest control rule) remains the same.
