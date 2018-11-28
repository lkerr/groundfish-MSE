



#Description of management strategy evaluation
#
#
**1\. Introduction**  
The objective of the management strategy evaluation is to determine what regulatory procedures may be the most effective given the dynamics of the population and fishery and especially considering expected environmental trends related to climate change.  Recruitment, growth, mortality and the assessment-management procedure process are modeled together so that the feedback from the management strategies on the population can be quantified.
The management components included were the stock assessment model, calculation of any necessary biological reference points for the management procedure and the harvest control rule.  Some of the management procedure components had the capacity to incorporate the types of environmental changes that were built into the simulations.
The model can only approximate the order and timing of events in the population and management complex.  Recruitment occurs instantaneously at the beginning of each year, immediately followed by instantaneous growth.  Fishing and natural mortality then operate through the rest of the year from Jan 1 – Dec 31.  Management (i.e., assessment and regulation-setting) occurs instantaneously at the end of the year and rules (i.e., fishing mortality in the next year) are implemented on Jan 1 with no lag time.

![Figure 1. Schematic of operating model.  Population processes growth and recruitment occur instantaneously at the beginning of the year while mortality occurs continuously throughout the year.  Temperature has the potential to impact each of the population processes and to be built directly into the management procedures. ](images/flow.jpg)

**2\. Population dynamics**  
Age structured model.  
**2\.1 Length-at-age**  
Length-at-age is modeled using the von Bertalanffy function  
\begin{equation}
\label{eq:eqn1}
L_{a,y} = L_{\infty}(1-e^{(-K(t-t_{0}))})
\tag{1}
\end{equation}

where $L_{a,y}$ is length at age $a$ in year $y$, $L_{\infty}$ is the asymptotic size, $K$ is the Brody growth coefficient and $t_0$ is a nuisance parameter that accounts for growth at small sizes.  Currently temperature is not built into this function but this is planned and is why $L_{a,y}$ has the subscript $y$ (i.e., temperature will change by year, meaning that length-at-age is a dynamic quantity).


**2\.2 Weight-at-age**  
Weight-at-age follows exponential growth of the form
\begin{equation}
\label{eq:eqn2}
W_{a,y} = {\lambda}L^{\psi}_{a,y}
\tag{2}
\end{equation}
where $W_a,y$ is weight at age $a$ in year $y$, $L_a,y$ is length at age $a$ in year $y$, and $a$ and $b$ are parameters.  The parameters $a$ and $b$ are not time varying (i.e., there is no direct temperature effect).  However, the weight-at-age will change over time with length-at-age.

**2\.3 Maturity-at-age**
Maturity-at-age follows a logistic pattern of the form
\begin{equation}
\label{eq:eqn3}
\theta_{a,y}=\frac{1}{1+e^{\upsilon(L_{50}-L_{ay})}}
\tag{3}
\end{equation}
where $\theta_{ay}$ is the maturity of age $a$ in year $y$ and $\upsilon$ and $L_{50}$ are stock-specific parameters .  Specifically, $L_{50}$ represents the length at which 50% of individuals are mature and $\upsilon$ defines the slope of the logistic function.

**2\.4 Recruitment**  
Recruitment is a central component of the MSE because it is directly affected by temperature.  In addition, stock recruitment relationships are notoriously difficult to measure.  Given the significance associated with this central model component it is important to ensure that both model expected values and various uncertainties are accounted for.  
#
** EDIT RECRUITMENT TEXT **  
#

**2\.5 Natural mortality**  
Natural mortality is a static value that applies to all age classes, fixed at 0.2.  

**2\.6 Exponential survival** 
Annual mortality is modeled (for ages younger than the plus age) using exponential survival
\begin{equation}
\label{eq:eqn4}
\\N_{a,y} = N_{a-1,y-1} e^{-\Phi^{F}_{a-1,y-1}F_{y-1}-M_{a-1,y-1}}
\tag{4}
\end{equation}
where $N_{a,y}$ is the January 1 numbers-at-age a in year $y$, $F$ is fishing mortality, $M$ is natural mortality-at-age and $\Phi^{F}$ is fishery selectivity (see Section 3.1).  Currently natural mortality is static but there is potential for this term to vary annually and over ages so $M$ is subscripted.  Plus group abundance in year $y$ is
\begin{equation}
\label{eq:eqn5}
\\N_{a^p,y} = N_{a^p-1,y-1} e^{-\Phi^{F}_{a^p-1,y-1}F_{y-1}-M_{a^p-1,y-1}} + 
              N_{a^p,y-1} e^{-\Phi^{F}_{a^p,y-1}F_{y-1}-M_{a^p,y-1}}
\tag{5}
\end{equation}
where $a^p$ is the plus age.

**3\. Fishery dynamics**
xxxx  
**3\.1 Fishery selectivity**
Fishery selectivity is a logistic function of the form
\begin{equation}
\label{eq:eqn6}
\Phi^F_{a,y} = \frac{1}{1+e^{s_0+s_1L_{a,y}}}
\tag{6}
\end{equation}
(note the different parameterization than for length-maturity) where $\Phi^F_{a,y}$ is the fishery selectivity of age $a$ fish in year $y$ and $s_0$ and $s_1$ are parameters that together govern the position of the curve and its slope.

**3\.2 Fishery catchability**
Fleet catchability is fixed at an arbitrary value of 0.001.

**3\.3 Catch**
Fishery catch in numbers is defined by the Baranov catch equation
\begin{equation}
\label{eq:eqn7}
\\C^N_{a,y} = \frac{\Phi^F_{a,y}F_y}{\Phi^F_{a,y}F_y+M_{a,y}}
             N_{a,y}(1-e^{-\Phi^F_{a,y}F_y-M_{a,y}})
\tag{7}
\end{equation}

where $\\C^N_{a,y}$ is the catch of age-a fish in year $y$ in numbers, $F_y$ is the fully selected fishing mortality in year $y$, and $N_{a,y}$ is the number of age-a individuals in the population in year $y$.  Catch in weight $\\C^W_{a,y}$ is
\begin{equation}
\label{eq:eqn8}
\\C^W_{a,y} = C^N_{a,y}W_{a,y}
\tag{8}
\end{equation}
As implied by this equation there is no difference in weight-at-age between the population and that observed in the fishery catch.




test reference $\ref{eq:eqn1}$

