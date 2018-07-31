

#!/bin/bash

#BSUB -W 03:59                            # How much time does your job need (HH:MM)
#BSUB -q short                            # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "runSim[1-1]"                    # Job Name
#BSUB -R rusage[mem=10000] 
#BSUB -n 1

#BSUB -o "./%J.o"
#BSUB -e "./%J.e"

#BSUB -w 'done(runPre)'  # DEPENDENCIES: wait until down with sleep100 job.





cd groundfish-MSE/

module load R/3.4.0 
# module load gcc/5.1.0

Rscript ./processes/runSim.R --vanilla
# Rscript $HOME/COCA/processes/runSim.R --vanilla


echo "runSim complete"


