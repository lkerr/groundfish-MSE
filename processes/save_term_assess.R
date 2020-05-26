################################
## code to extract and save terminal assessment year across simulations
##

# create new folder to put assessment results in
dir.create('./groundfish-MSE/results/term_assessment')


# find results folders
folders <- list.files('./groundfish-MSE/assessment/ASAP')
folders <- folders[-1]

# extract terminal assessment year
for(i in 1:length(folders)){
file.copy(from = paste('./groundfish-MSE/assessment/ASAP/', folders[i], '/codGOM_1_200.rdat', sep = ''), to = './groundfish-MSE/results/term_assessment')
}
