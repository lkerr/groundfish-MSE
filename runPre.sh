
#!/bin/bash

#BSUB -W 00:59                            # How much time does your job need (HH:MM)
#BSUB -q short                            # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "runPre"                    # Job Name
#BSUB -R rusage[mem=10000] 
#BSUB -n 1

#BSUB -o "./%J.o"
#BSUB -e "./%J.e"



# run.sh is located inside git transfer directory here,
# but when run on HPCC it is assumed that run.sh will be
# one level up from the root directory. The first thing that
# happens is run.sh downloads the most up-to-date version from
# github so we want it outside the root directory so that run.sh
# isn't part of what gets deleted before the download.

# 17d3b37aa4080198a25fe421470b97f92af26794


# remove old directory
rm -r -f groundfish-MSE/

# load the git module
module load git/2.1.3

# clone the current repository
git clone -b master https://samtruesdell:17d3b37aa4080198a25fe421470b97f92af26794@github.com/COCA-NEgroundfishMSE/groundfish-MSE

# load the gcc module for compilation
module load gcc/5.1.0

# load R module
module load R/3.4.0

# load module to run ASAP.exe on unix
module load wine

cd groundfish-MSE/

Rscript ./processes/runPre.R --vanilla

echo "runPre complete"
