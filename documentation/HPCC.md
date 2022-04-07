**MSE Framework: High Performance Computing Cluster (HPCC)**

After you get access to the UMass Dartmouth HPCC, you will need to download PuTTY 
(https://www.putty.org/) and WinSCP (https://winscp.net/eng/index.php). 

Upload files needed to WinSCP.

-Folder called EXE with ASAP3.EXE file

-Folder called .config with rclone folder inside which has a file called ‘rclone.conf’

-Folder called Rlib with all R libraries needed

-run.sh, runPre.sh, runSim.sh, and runPost.sh files

To use the HPCC:

1. Enter ‘ghpcc06.umassrc.org’ in the Host Name box in PuTTY and click ‘Open’. 
2. Enter your username and password. 
3. Enter ‘cd HPCC’. 
4. Sign in on WinSCP. Enter the host name (ghpcc06.umassrc.org), your username and password, and 
click ‘Login’. 
5. Enter ‘bsub<run.sh’ on PuTTY. 

documentation/hpccUMASS_intro.md
-introduction to the HPCC

documentation/hpccUMASS_getLibs.md
-documentation on installing R libraries on your HPCC account

documentation/hpccUMASS_batchJobs.md
-documentation on running scripts in sequence using batch jobs

run.sh
-shell file to run simulation setup, simulations, and output

runPre.sh
-shell file to prepare files for simulations

runSim.sh
-shell file to run simulations

runPost.sh
-shell file to get output from simulations
