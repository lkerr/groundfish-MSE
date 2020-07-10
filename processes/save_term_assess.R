################################
## code to extract and save terminal assessment year across simulations
##

# create new folder to put assessment results in
tempwd <- getwd()
new.dir <- paste(tempwd, "/results/term_assessment", sep = '')
dir.create(new.dir)


# find results folders
folders <- list.files('./assessment/ASAP')
folders <- folders[-1]

# extract terminal assessment year
for(i in 1:length(folders)){
  rand.num <- sample(1:10000, 1)
  from_path <- paste("./assessment/ASAP/", folders[i], "/codGOM_1_200.rdat", sep = "")
  to_path <- paste(new.dir, '/', rand.num, '.rdat', sep = '')
  file.copy(from = from_path, to = to_path)
}
