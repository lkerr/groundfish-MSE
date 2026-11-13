# This script is downloaded from gitHub
# It makes the new results folder, submits 
echo "********** Setup **********"

#load modules for R... THIS MIGHT NOT BE NECESSARY AS IT NEEDS TO ALSO HAPPEN WITHIN THE SLURM SBATCH SCRIPT?
module load gnu12/12.2.0
module load R/4.4.1

# datetime stamp and results directory
dt=$(date +'%Y-%m-%d-%H-%M-%S')   # datetime stamp, used to make results directory and tag simulations wihtin the R scripts
echo $dt   # print the datetime stamp
mkdir "results_$dt"    # make a new results directory with the datetime stamp

# Run the batch script
echo "********** Run Batch *********"
ID=$(sbatch --parsable ./SubmitJob_MSEarray.sh)   # Submit array job and capture the job id to use in dependency below

echo MSE array is job number $ID
echo "********** Submitted Batch *********"

# Collate the results
#echo "********** Submit collation job **********"
sbatch --dependency=afterany:$ID ./SubmitJob_CollateArray.sh

# echo "********** Collation job submitted with dependency **********"