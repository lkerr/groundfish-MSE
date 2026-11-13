#!/bin/bash

#SBATCH --job-name=collate           # Job name
#SBATCH --partition=haswell           # Partition/Queue name
#SBATCH --mail-type=END,FAIL          # Mail events
#SBATCH --mail-user=john.brothers@maine.edu   # Where to send mail
#SBATCH --ntasks=1                    # Run a single task
#SBATCH --cpus-per-task=1             # Run with 1 threads
#SBATCH --mem=5gb                    # Job memory request
#SBATCH --time=0:30:00               # Time limit hrs:min:sec
#SBATCH --output=collate_%j.log          # Standard output and error log
#SBATCH --export=ALL

module load gnu8/8.3.0
module load R/4.2.2
Rscript ./Processes/CollateHPCarray.R

echo " collation job complete"