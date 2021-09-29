<h1> New England Groundfish Management Strategy Evaluation</h1>
<p> This tool allows users to explore the performance of alternative harvest control rules in managing New England groundfish. </p>

<h3> Specifications </h3>
<p> First, the user can specify some of the parameters defining the simulations using the <strong> Specifications </strong>tab. 
<p>
<ul>
<li><strong>Stock</strong>: This option allows the user to select either the Georges Bank cod or Georges Bank haddock stock.</li>
<li><strong>Stock assessment uncertainty</strong>: Select the amount of uncertainty in stock assessment estimations.</li>
<li><strong>Stock assessment biomass estimation bias</strong>: Select the level of bias of biomass estimations by the stock assessment model.</li>
<li><strong>Climate scenario</strong>: The user can select no climate scenario, or the lower bound, median, or upper bound of the emissions as usual (RCP  8.5) climate change scenario. Climate change affects the stock-recruitment relationship. </li>
<li><strong>Number of simulations</strong>: Input the number of simulations or iterations. This only matters when there is stock asssessment uncertainty.</li>
<li><strong>Number of projection years</strong>: Input the number of projection years, or the number of years simulated into the future.</li>
</ul>

<h3> Harvest Control Rule Projections </h3> 
Then, the user can specify the HCR to apply using the <strong> HCR Projections </strong>tab. The HCR can be one of four forms: <strong>constant catch</strong>, <strong>constant fishing mortality</strong>, <strong>threshold</strong>, and <strong>ramped</strong>. Each form has different input: </p>
<p> <strong>Constant catch:</strong></p>
<ul>
<li>Select <strong>Constant catch</strong> under <em>Type of harvest control rule.</em></li>
<li>Input a constant catch.</li>
<li>Press <strong>Do projections</strong> button.</li>
</ul>
</p>
<p> <strong>Constant fishing mortality:</strong></p>
<ul>
<li>Select <strong>Constant fishing mortality</strong> under <em>Type of harvest control rule.</em></li>
<li>Input a constant fishing mortality (F).</li>
<li>Press <strong>Do projections</strong> button.</li>
</ul>
</p>
<p> <strong>Threshold:</strong></p>
<ul>
<li>Select <strong>Threshold</strong> under <em>Type of harvest control rule.</em></li>
<li>Use the slider to select a maximum F (as a fraction of <em>F</em><sub>MSY</sub>).</li>
<li>Use the slider to select the spawning stock biomass (SSB) limit (relative to <em>B</em><sub>MSY</sub>) at which F decreases to 0.</li>
<li>Press <strong>Do projections</strong> button.</li>
</ul>
<p> <strong>Ramped:</strong></p>
<ul>
<li>Select <strong>Ramped</strong> under <em>Type of harvest control rule.</em></li>
<li>Use the slider to select a maximum F (as a fraction of <em>F</em><sub>MSY</sub>).</li>
<li>Use the slider to select the SSB limit (relative to <em>B</em><sub>MSY</sub>) at which F begins to decrease.</li>
<li>Press <strong>Do projections</strong> button.</li>
</ul>
<p>
<p> It is recommended to run 3-4 HCR scenarios to be able to compare scenarios in the next tab. Four plots will appear: the proportion of SSB to the SSB reference point, the proportion of F to the F reference point, catch over time, and recruits over time. The proportion of SSB to the SSB reference point indicates whether the fishery is overfished or not. The proportion of F to the F reference point indicates whether the fishery is undergoing overfishing or not. Recruits are the number of fish that are born that year.

<h3> Compare Scenarios </h3>
On the <strong> Compare Scenarios </strong>tab, the user can compare the different scenarios tested in the <strong> HCR Projections </strong>tab by clicking <strong> Compare Scenarios</strong>. A table will appear that compares some outputs from the different scenarios. A spider plot will also appear that illustrates tradeoffs between the different HCRs. 

<h3> Funding and support </h3>
<p> This tool was modified from the MSE tool developed by Andr&eacute; E. Punt. This tool was funded by the Arthur Vining Davis Foundation. </p>

