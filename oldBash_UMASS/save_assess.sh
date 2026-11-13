#!/bin/bash

#BSUB -W 00:59                            # How much time does your job need (HH:MM)
#BSUB -q short                            # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "save_assess"                    # Job Name
#BSUB -R rusage[mem=10000] 
#BSUB -n 1

#BSUB -o "./%J.o"
#BSUB -e "./%J.e"



# load the gcc module for compilation
module load gcc/5.1.0

# load R module
module load R/3.4.0

cd groundfish-MSE/

Rscript ./processes/save_term_assess.R 

echo "save assessment complete"
