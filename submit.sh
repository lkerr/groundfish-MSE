#!/bin/bash
#
#SBATCH --array=0-99
#SBATCH --cpus-per-task=1
#SBATCH --job-name=HPCfunsim_Feb17
#SBATCH --output=slurm_%a.out
#SBATCH --time=100:00:00
#SBATCH --nodes=1
#SBATCH --account=dfo_pfm__large
#SBATCH --partition=large
#SBATCH --export=USER,LOGNAME,HOME,MAIL,PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#SBATCH --qos=low
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=25GB
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=mackenzie23mazur@gmail.com
cd /fs/vnas_Hdfo/comda/mam006/Documents/mam006/groundfish-MSE/_rlsurm_HPCfunsim_Feb17
(export TMPDIR='/gpfs/fs7/dfo/hpcmc/pfm/mam006/temp' ;
export R_LIBS_USER='/gpfs/fs7/dfo/hpcmc/pfm/mam006/rlib/4.3'; /usr/bin/Rscript --vanilla slurm_run.R )
