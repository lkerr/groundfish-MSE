# FunctionTree describes how nested functions interact
# Information is passed from most general to most specific functions (i.e. terminal nodes perform calculations required by all upstream nodes)

library(DiagrammeR)
# Add hyperlinks
# https://stackoverflow.com/questions/48792355/inserting-hyperlinks-into-node-labels-in-diagrammer
# More specific/tailored nodes
# https://rich-iannone.github.io/DiagrammeR/graphs.html
# Formatting options
# https://rich-iannone.github.io/DiagrammeR/graphviz_and_mermaid.html

grViz("

digraph boxes_and_circles{

## Add node statements
# Define shape
node[shape = box] # OR box, circle, optional fontname/penwidth options
# Define node content
calc_ABC
calc_pstar
get_advice
get_ASAP
get_AssessVals
get_BBRP
get_bio_for_econ
get_bounds # Defined in get_tmbSetup line 121/129? Also in assessment folder?
get_burnF
get_caa
get_catch
getCW
get_dwindow
get_error_idx
get_error_paa
get_estF
get_F
get_FBRP
get_fillRepArrays
get_fishery_next_period_areaclose
get_fmed
get_HistAssess
get_implementationF
get_indexData
get_init
get_J1Ny
get_J1Updates
get_joint_production
get_lengthAtAge
get_LMdevs
get_maturity
get_mortality
get_nextF
get_perRecruit
get_planB
get_PopesF
get_popInit
get_predict_eproduction
get_predict_etargeting
get_proj
get_projnolag
get_random_draw_tripsDT
get_recruits
get_relE
get_relError
get_replacement
get_reshape_catches
get_reshape_landings
get_RWdevs
get_slideHCR
get_slx
get_survey
get_svNoise
get_tempslideHCR
get_TermrelError
get_tmbSetup
get_weightAtAge
joint_adjust_allocated_mults
joint_adjust_others
zero_out_closed_areas_asc_cutout

# Need formatted as a function (rough outline - processes)
runSim # Needs to be formatted as function
runSetup
identifyResultDirectory
get_runinfo


# Add edge statements to connect nodes
edge[] # optional arrowhead options
# Connect nodes (may be labeled - appears on line)
runSim -> runSetup; runSetup -> identifyResultDirectory;
runSetup -> get_runinfo;
runSetup -> calc_Tanom; calc_Tanom -> get_temperatureSeries; calc_Tanom -> get_temperatureProj;  # calc_Tanom previously genAnnStructure !!!
runSetup -> Rfun_BmsySim;
runSetup -> genBaselineACLs;

get_advice -> get_ASAP; get_ASAP -> get_dwindow;
get_advice -> get_caa; get_caa -> get_svNoise;
get_advice -> get_nextF;
get_advice -> get_planB; get_planB -> ApplyPlanBsmooth; get_planB -> get_dwindow;
get_advice -> get_tmbSetup;
get_BBRP -> get_perRecruit;
get_BBRP -> get_proj;
get_estF -> get_F;
get_F -> getCW;
get_FBRP -> get_fmed;
get_FBRP -> get_perRecruit;
get_FBRP -> get_proj;
get_FBRP -> get_replacement;
get_implementationF -> get_catch;
get_implementationF -> get_error_idx;
get_implementationF -> get_F;
get_implementationF -> get_PopesF;
get_J1Updates -> get_AssessVals;
get_J1Updates -> get_catch;
get_J1Updates -> get_J1Ny; # get_J1NY function file name actually contains get_J1Ny function
get_J1Updates -> get_lengthAtAge;
get_J1Updates -> get_maturity;
get_J1Updates -> get_recruits;
get_J1Updates -> get_slx;
get_J1Updates -> get_weightAtAge;
get_mortality -> get_catch;
get_nextF -> calc_ABC;
get_nextF -> calc_pstar;
get_nextF -> get_BBRP;
get_nextF -> get_estF;
get_nextF -> get_FBRP;
get_nextF -> get_proj; 
get_nextF -> get_projnolag;
get_nextF -> get_slideHCR;
get_nextF -> get_tempslideHCR;

get_planB -> ApplyPlanBsmooth;
get_planB -> get_dwindow;
get_popInit -> get_burnF;
get_popInit -> get_catch;
get_popInit -> get_init;
get_popInit -> get_lengthAtAge;
get_popInit -> get_maturity;
get_popInit -> get_slx;
get_popInit -> get_survey;
get_popInit -> get_weightAtAge;
get_proj -> get_dwindow;
get_proj -> get_error_idx;
get_proj -> get_error_paa;
get_proj -> get_F;
get_projnolag -> get_dwindow;
get_projnolag -> get_error_idx;
get_projnolag -> get_error_paa;
get_projnolag -> get_F;
get_recruits -> get_HistAssess;
get_relError -> get_dwindow;
get_relError -> get_relE;
get_TermrelError -> get_relE;
get_tmbSetup -> get_bounds;
get_tmbSetup -> get_dwindow;
get_tmbSetup -> get_LMdevs;
get_tmbSetup -> get_RWdevs;


runEcon_module -> get_F;
runEcon_module -> get_fishery_next_period_areaclose;
runEcon_module -> get_joint_production;
runEcon_module -> get_predict_eproduction;
runEcon_module -> get_predict_etargeting;
runEcon_module -> get_random_draw_tripsDT;
runEcon_module -> get_reshape_catches;
runEcon_module -> get_reshape_landings;
runEcon_module -> joint_adjust_allocated_mults;
runEcon_module -> joint_adjust_others;
runEcon_module -> zero_out_closed_areas_asc_cutout;
runSim -> get_advice;
runSim -> get_bio_for_econ;
runSim -> get_fillRepArrays;
runSim -> get_HistAssess;
runSim -> get_implementationF;
runSim -> get_indexData;
runSim -> get_J1Updates;
runSim -> get_mortality;
runSim -> get_popInit;
runSim -> get_relError
runSim -> runEcon_module; # Needs updating
runSim -> get_survey;
runSim -> get_TermrelError;
runSim -> setTxtProgressBar;

# Add graph statement
graph[nodesep = 0.1, rankdir = LR] # set distance between nodes
#graph[nodesp=0.1]
}
")


##### Other setup functions
grViz("
digraph boxes_and_circles{
## Add node statements
node[shape = box]
Apply_PlanBsmooth # file labeled as apply_PlanBsmooth
generateMP # In processes, needs to be formatted as function
get_bio_for_econ_only
get_containers
get_mprocCheck
Rfun_BmsySim # List of functions defined for reference?
runEcon_module
runSetup # Needs to be formatted as function
runSim_Econonly
setupYearIndexing_Econ
txtProgressBar


edge[]
generateMP -> get_mprocCheck;
runSetup -> get_containers;
runSim_Econonly -> get_bio_for_econ_only;
setupYearIndexing_Econ -> txtProgressBar;

# Add graph statement
graph[nodesep = 0.1, rankdir = LR] # set distance between nodes

}   
")


##### genAnnStructure functions
grViz("
digraph boxes_and_circles{

## Add node statements
node[shape = box]
genAnnStructure # Needs to be formatted as a function
get_temperatureProj
get_temperatureSeries
anomFun

# Add edge statements to connect nodes
edge[]
genAnnStructure -> get_temperatureProj;
genAnnStructure -> get_temperatureSeries;
genAnnStructure -> anomFun;

# Add graph statement
graph[nodesep = 0.1, rankdir = LR] # set distance between nodes
}

")


##### Post processing functions
grViz("
digraph boxes_and_circles{

## Add node statements
# Define shape
node[shape = box] # OR box, circle, optional fontname/penwidth options
# Define node content
get_catdf
get_memUsage
get_plots # Check that uses get_stability function
get_simcat
runPost # Needs to be formatted as a function

# Add edge statements to connect nodes
edge[] # optional arrowhead options
# Connect nodes (may be labeled - appears on line)
runPost -> get_catdf;
runPost -> get_memUsage;
runPost -> get_simcat;
runPost -> get_plots;

# Add graph statement
graph[nodesep = 0.1, rankdir = LR] # set distance between nodes
}
")

# ##### May be added later
# # From management procedure folder
# get_BmsySim # ???Maybe not used
# get_parRP # ???Maybe not used
# get_Tmin # ???Maybe not used
# pstar # or getFpstar? or calc-pstar???
# 
# # From pop dy folder
# get_ieF # ???Maybe not used
# get_M # ???Maybe not used
# get_recruitment_par # ???Maybe not used
# 
# # From assessment folder
# prepFiles
# get_WAA_pointers # ???Maybe not used
# get_sel_block_assign # ???Maybe not used
# get_sel_ini # ???Maybe not used
# get_prop_rel_mats # ???Maybe not used
# editComments # ???Maybe not used
# 
# # Need to add functions from economic folder
# get_bio_for_econ_only #??? Maybe not used
# get_fishery_next_period #??? Maybe not used
# get_predict_eproductionCpp #??? Maybe input file?
# get_predict_etargetingCpp #??? Maybe input file?
# get_reshape_targets_revenues #??? Maybe not used
# zero_out_closed_asc_cutout #??? Maybe not used
# 
# # From Main folder
# get_gini # ???Maybe not used
# get_proj_retired # Not used
# get_stability # Maybe used in plotResults/get_plots.R??? check this
# 










