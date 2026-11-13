

#!/bin/bash

#BSUB -W 00:15                            # How much time does your job need (HH:MM)
#BSUB -q short                            # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "runNoGit"                    # Job Name
#BSUB -R rusage[mem=10000] 
#BSUB -n 1

#BSUB -o "./%J.o"
#BSUB -e "./%J.e"


bsub < runPreNoGit.sh
bsub < runSim.sh
bsub < runPost.sh

echo "run complete"
