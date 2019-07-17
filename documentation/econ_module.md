

# Economic module documentation
### Min-Yang Lee; Anna Birkenbach (Min-Yang.Lee@noaa.gov; abirken@udel.edu)

<br> Describes the code that implements the "Economic Simulation Module" in the management strategy evaluation

***

### What is Beneath Economic module
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

Catchability $q$ varies by vessel-target.  The results are used to predict expected harvest of target $n$. These are then adjusted to account for the jointness in catching fish. For example, a trip that is targeting GB cod and that lands 1000 lbs of GB cod is also likely to land 500 lb of GB haddock, 200 lb of pollock, and 80 lb of skates.  We track all these and multiply by expected prices to construct expected revenue for vessel $i$'s trip that targets GB cod on day $t$. We repeat for all $i$,$n$, $t$ to construct expected revenue for all feasible choices.

In the second stage, we estimate the probability that a vessel will target "thing" t: 
\begin{equation}
P[Target_{nit}] =P(Revenues_{nit}, Costs_{nit}, Z_{nit})
\end{equation}
We observe whether the vessel actually targeted a thing or did not. These statistical models are referred to as discrete-, binary-, or multinomial- choice models.  The theoretical model underneath this is a Random Utility Model.  Currently, we're using an Alternative-specific Conditional Logit, but we're exploring other options, including nested and mixed logits. Estimation of the asc logit is by maximum likelihood (or quasi-ML, can't remember).

We can simulate either the production or targeting equations at any values of the explanatory variables: for example changes in the trawl survey (used as a biomass proxy) can affect changes in harvest, which feeds into expected revenue and eventually the target equation.  Changes in costs or weather would directly affect the targeting equation. 

We can also simulate what happens when a fishery (GOM Cod, Pollock, Skates) are closed -- how does fishing effort redistribute to other targets?

McFadden,  D.  L.  1974.  Conditional  logit  analysis  of  qualitative  choice  behavior.  In Frontiers  in  Econometrics,  ed.P.  Zarembka,  105–142.  New  York:  Academic  Press

For both the production and targeting models, the unit of observation is a permit-day.

The statistical estimation of the model takes place externally to the MSE model -- there isn't a need to have this occur simultaneously (yet).

### The R code
There's a pile of code. It's quite janky.
    
* **predict_eproduction:** 

* **predict_etargeting:** 



### Inputs
Data, starting values and parameter bounds are XXX.



### Outputs
Model outputs are XXX



### Notes
* Here is a note

[Return to Wiki Home](https://github.com/thefaylab/groundfish-MSE/wiki)
