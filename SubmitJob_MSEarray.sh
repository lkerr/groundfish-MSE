#!/bin/bash

#SBATCH --job-name=NEFMC_MSEarray              # Job name
#SBATCH --partition=haswell                    # Partition/Queue name
#SBATCH --mail-type=END,FAIL                   # Mail events
#SBATCH --mail-user=john.brothers@maine.edu    # Where to send mail
#SBATCH --ntasks=1                             # Run a single task
#SBATCH --cpus-per-task=1                      # Run with 1 threads
#SBATCH --mem=10gb                             # Job memory request
#SBATCH --time=6:00:00                         # Time limit hrs:min:sec
#SBATCH --output=%x_%A_%a.log                  # Output and error log named by array task ids
#SBATCH --array=1-10                           # Number of arrays to run (how many repetitions of the R script)
#SBATCH --export=ALL                           # Exports the environment variables into the batch job (dt and array numbers, etc.)

module load gnu12/12.2.0
module load R/4.4.1
Rscript ./processes/runSim.R

echo "MSE array task complete"