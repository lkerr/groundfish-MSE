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

# Run the batch script with a SLURM array
echo "********** Run Batch *********"
ID=$(sbatch --parsable --output="results_$dt/%x_%A_%a.log" ./SubmitJob_MSEarray.sh)   # capture the job id for later dependency, save log in results directory

echo MSE array is job number $ID
echo "********** Submitted Batch *********"

# Collate the results !!!!!! NEED TO MODIFY COLLATION CODE FOR groundfish-MSE once array is running and saving appropriately
# echo "********** Submit collation job **********"
# sbatch --dependency=afterany:$ID ./SubmitJob_CollateArray.sh

# echo "********** Collation job submitted with dependency **********"