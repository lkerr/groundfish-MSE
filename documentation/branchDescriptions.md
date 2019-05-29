

# Branch descriptions

--------

## How to use this file

There is no easy way to describe branches directly on GitHub. This file provides a place to do that.  When you create a branch, add a short description to this file under the heading **Active branches**. If you delete a branch or you are not currently working on it (i.e., it moves to *stale* status on GitHub) -- or you notice someone else's stale branch -- copy the description from **Active branches** down to **Stale / deleted branches** and commit the change.

--------

## Additional related resources

For general information on GitHub workflows and how to use branches, see [groundfish-MSE/documentation/gitHubWorkflow.md](gitHubWorkflow.md))

--------

## Perpetual branches

* **Master**: The master branch. This branch should not be edited directly.  Merges to **Master** must be peer-reviewed as this branch is expected to work at all times.

* **Dev**: The development branch.  In general this branch should not be edited directly except for changes to help files / comments and potentially other small changes that are known for sure not to impact functionality. Merges to **Dev** should be peer-reviewed as this branch is expected to work at all times.

--------
## Active branches

* **Economic_model**: Scripts dedicated to integrating Anna and Min-Yang's economic model.

* **forecastForBRP**: Updating the biological reference point MPs to include forecasts that mirror hindcasts in simulations. Options are to use recruitment estimates from the assessment model that go back *n* years or to use forecasts based on a S/R function that look forward *n* years.

* **multistock**: Branch dedicated to developing the initial multistock approach where management & fishing are applied to stocks in order via loops.

* **realized_catch**: Branch dedicated to developing and integrating the alternative implementations of the management advice, i.e., producing the realized catch given the harvest regulation.  


--------
## Stale / deleted branches

* **implementSteepnessFunction**: Adding functionality for the steepness parameterization of the Beverton-Holt stock-recruitment relationship.

* **inclCAArelError**: Incorporate relative error in the CAA model as an internal performance metric.

* **ReorganizePlotData**: Edits to plotting protocols.

* **editRecruitment**: Edits to recruitment functions.

* **recFunEdits**: Edits to recruitment functions.

* **initPopExponentialDeclineCAA**: Initial population in the CAA model derived from exponential decay rather than estimating a mean and deviations.

* **varyRecPredsInSSB_RP**: Edits to recruitment functions within reference point determination.

* **createFmsyOption2**: Editing reference points.

* **HadGB**: Added Haddock population information to parameter file.

* **YtfGB**: In the process of adding yellowtail population information to parameter file.

[Return to Wiki Home](https://github.com/thefaylab/groundfish-MSE/wiki)
