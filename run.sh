

#!/bin/bash

#BSUB -W 00:15                            # How much time does your job need (HH:MM)
#BSUB -q short                            # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "samsim[1-1]"                    # Job Name
#BSUB -R rusage[mem=1000] 

#BSUB -o "./%J.out"
#BSUB -e "./%J.err"



# run.sh is located inside git transfer directory here,
# but when run on HPCC it is assumed that run.sh will be
# one level up from the root directory. The first thing that
# happens is run.sh downloads the most up-to-date version from
# github so we want it outside the root directory so that run.sh
# isn't part of what gets deleted before the download.


# remove old directory
rm -r -f groundfish-MSE/

# load the git module
module load git/2.1.3

# clone the current repository
git clone https://github.com/COCA-NEgroundfishMSE/groundfish-MSE

cd groundfish-MSE/

module load R/3.4.0 
module load gcc/5.1.0

Rscript ./processes/runSim.R --vanilla
# Rscript $HOME/COCA/processes/runSim.R --vanilla






# #BSUB "span[hosts=1]"                     #Memory useage

# Name the output and error files