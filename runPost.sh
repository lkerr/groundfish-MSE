
#!/bin/bash

#BSUB -W 07:00                            # How much time does your job need (HH:MM)
#BSUB -q long                            # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "runPost"                    # Job Name
#BSUB -R rusage[mem=10000] 
#BSUB -n 1

#BSUB -o "./%J.o"
#BSUB -e "./%J.e"

#BSUB -w 'done(runSim[1-100])'  # DEPENDENCIES: wait until down with simulation job.



module load R/3.4.0

cd groundfish-MSE/
Rscript ./processes/runPost.R --vanilla

module load rclone/1.51.0
rclone copy ~/HPCC/groundfish-MSE/ --include "{results_}**" HCRSims:Mackenzie_Mazur/HCR_Sims

echo "runPost complete"