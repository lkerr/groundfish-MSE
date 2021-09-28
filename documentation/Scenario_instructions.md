------------------------------------------------------------------------

### Running different settings on the discard simulation branch

-   *The default saved settings on GitHub are for accumulating
    assessment data, M = 0.2, changepoint bias in 2015, no catch bias
    scenario, slide HCR*

-   *These changes can be made locally and pushed to GitHub to use
    ‘run.sh’ OR they can be made on the HPCC after submitting
    ‘runPre.sh’*

### Options:

1.  Moving window of stock assessment data: change ASAP assessment start
    year by uncommenting lines 23/24 and commenting out lines 19/20 in
    ‘get\_ASAP.R’
2.  Uniform observation bias in catch weight: remove conditional start
    year for observation bias by commenting out lines 30-35, and 39 in
    ‘get\_indexData.R’
3.  M-ramp natural mortality: change OM/ASAP parameters and historic
    data read in by using commented out parameter lines for M, M\_type,
    selC, and Rpar (39,40,61,72,73) in GOMcod.R. To read in historic
    assessment F/R/M it is expecting a file named ‘codGOM.csv’ which
    currently has the M = 0.2 information. The
    data/data\_raw/AssesmentHistory/codGOM\_highM.csv has the M-ramp
    information but needs to be renamed to ‘codGOM.csv’.
4.  Catch bias scenarios: simultaneously change the values of
    ‘ob\_sumCW’ and ‘C\_mult’ in codGOM.R

<table>
<thead>
<tr class="header">
<th>Scenario</th>
<th>Catch bias level</th>
<th>C_mult</th>
<th>Observation bias level</th>
<th>Obs_sumCW</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Perfect accounting</td>
<td>0%</td>
<td>0</td>
<td>0%</td>
<td>1</td>
</tr>
<tr class="even">
<td>Slight bias</td>
<td>+50%</td>
<td>0.5</td>
<td>-33%</td>
<td>0.67</td>
</tr>
<tr class="odd">
<td>Large bias</td>
<td>+125%</td>
<td>1.25</td>
<td>-56%</td>
<td>0.44</td>
</tr>
<tr class="even">
<td>Extreme bias</td>
<td>+200%</td>
<td>2.0</td>
<td>-67%</td>
<td>0.33</td>
</tr>
</tbody>
</table>

1.  Constant harvest control rule: modify mproc.txt HCR from slide to
    constF

------------------------------------------------------------------------
