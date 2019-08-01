
# Running the MSE
#### (Sam Truesdell struesdell@gmri.org)


Provides an step-by-step description of how to run the MSE code -- focused on using the the UMASS GHPCC which is the complicated part. Local run instructions also included.  HPCC runs assume that:
1. You already have an account so you can use the UMASS computer cluster.  If you don't see the section *Request access to the Cluster* in the file [documentation/hpccUMASS_intro.md](hpccUMASS_intro.md)
2. You have already installed the necessary R libraries within your UMASS HPCC.  If you haven't done this already see the file [documentation/hpccUMASS_getLibs.md](hpccUMASS_getLibs.md)

***

### Running locally
Typically HPCC runs will have the **nrep** parameter -- which governs the number of independent simulations to run -- set to a low value like 1 or 2 in [modelParameters/set_om_parameters.R](../modelParameters/set_om_parameters_global.R). This is because the repetitions are done instead in parallel by the HPCC so each individual instance does not need many repetitions. Test runs on a local machine may have **nrep** set as low as 2 (if you set it to 1 there will be a warning -- this is simply because of downstream issues -- e.g., with plotting -- if there is only a single repetition). For a local run simply set **nrep** to the desired number of simulations and source the [processes/runSim.R](../processes/runSim.R) code (along with any other changes to the [modelParameters/set_om_parameters_global.R](../modelParameters/set_om_parameters_global.R) and [modelParameters/mproc.txt](../modelParameters/mproc.txt) files). In RStudio you can do this by opening the [modelParameters/runSim.R](../modelParameters/runSim.R) and pressing the **Source** button in the upper-right corner of the script window. Or, if you aren't using RStudio, in the R console you could type ```source('processes/runSim.R')``` (assuming groundfish-MSE was your working directory). Local runs work well, especially for testing, but for lots of repetitions they are too slow and you are better off using the HPCC.

### Summary of HPCC runs
The MSE is run on the UMASS HPCC as a batch job.  If you are unfamiliar with batch jobs it would probably be worthwhile to read the example under [documentation/hpccUMASS_batchJobs.md](hpccUMASS_batchJobs.md).  The premise is that this job is divided into three parts:

1. Setup. The repository is cloned from Git-Hub to the user's HPCC account.  A results directory is created and the assessment model is compiled.

2. Simulation.  The core MSE code is run *n* times simultaneously (sort of), each run on a different HPCC machine and the results for each run are saved as .Rdata files.

3. Compilation.  The results from each of the individual simulation runs are compiled and summaries and plots are produced.

***

### Preparing for a run

Four files are required to run the MSE.  They are: *run.sh*, *runPre.sh*, *runSim.sh* and *runPost.sh*  These need to be located in the same directory.  This is the directory where the folder **groundfish-MSE** will be located after it is cloned from Git-Hub.  Once the files are uploaded they can stay in the directory (i.e., you don't need to upload them every time you intend to run the MSE).

The four files are listed in turn below.  You can copy them individually into a new text document on your local machine and save them (with the appropriate .sh extension), then upload them to the appropriate folder in your HPCC account.  Notably, if you are working on a Windows (or presumably Mac) machine you will need to convert each of the files to Unix/Linux structure (the HPCC runs Linux).  This is due to differences in how the systems treat line breaks.  Once you have uploaded each of the files, use the command ```dos2unix``` for the conversion on each of the four files.  The inputs and outputs will look something like:
```
[st12d@ghpcc06 COCA_HPCC]$ dos2unix run.sh
dos2unix: converting file run.sh to UNIX format ...
```
```
[st12d@ghpcc06 COCA_HPCC]$ dos2unix runPre.sh
dos2unix: converting file runPre.sh to UNIX format ...
```
```
[st12d@ghpcc06 COCA_HPCC]$ dos2unix runSim.sh
dos2unix: converting file runSim.sh to UNIX format ...
```
```
[st12d@ghpcc06 COCA_HPCC]$ dos2unix runPost.sh
dos2unix: converting file runPost.sh to UNIX format ...
[st12d@ghpcc06 COCA_HPCC]$
```

Below each of the files is described in turn. But first a description of some of the common elements.  Each of the files has headers that give instructions about the job -- the headers start with #BSUB.
* ```#BSUB -W``` indicates how much time your job needs in hh:mm format

* ```#BSUB -q``` indicates which queue the job should be submitted to.  Have only used the "short" queue for this project.
* ```#BSUB -J``` the name of the job (in quotations)

* ```#BSUB R``` the memory requirements (in MB) -- this is something that may have to be evaluated and changed as you run larger sets of simulations

* ```#BSUB -o``` all runs produce printed output both specific to the HPCC job and anything printed by the program -- this argument specifies the name of the output file

* ```#BSUB -e``` specifies the name of the error file -- any errors that are produced by the run (either on the HPCC side or that are specific to the program) are recorded here.

### run.sh
The *run.sh* file is simply a control file.  It specifies that first *runPre.sh* should be submitted to the queue, then *runSim.sh*, and finally *runPost.sh* (```bsub < x``` submits the job named x).  When running the MSE, this is the only file that you need to submit directly (i.e., when you are ready to run all you have to do is type ```bsub < run.sh``` and hit Enter.)  The job submission must occur from where the four .sh files are located.
```
#!/bin/bash

#BSUB -W 00:15                # How much time does your job need (HH:MM)
#BSUB -q short                # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "run"                # Job Name
#BSUB -R rusage[mem=1000]     # Memory requirements (in MB)
#BSUB -n 1                    # Number of nodes to use
#BSUB -o "./%J.o"             # Specifies name of the output file
#BSUB -e "./%J.e"             # Specifies name of the error file


bsub < runPre.sh             # Submit job runPre.sh
bsub < runSim.sh             # Submit job runSim.sh
bsub < runPost.sh            # Submit job runPost.sh

echo "run complete"          # Print statement indicating job is done
```

### runPre.sh
```
#!/bin/bash

#BSUB -W 00:59                # How much time does your job need (HH:MM)
#BSUB -q short                # Which queue
#BSUB -J "runPre"             # Job Name
#BSUB -R rusage[mem=1000]     # Memory requirements (in MB)
#BSUB -n 1                    # Number of nodes to use
#BSUB -o "./%J.o"             # Specifies name of the output file
#BSUB -e "./%J.e"             # Specifies name of the error file


rm -r -f groundfish-MSE/     # remove old directory

module load git/2.1.3        # load the git module

# clone the repository
git clone https://samtruesdell:17d3b37aa4080198a25fe421470b97f92af26794@github.com/COCA-NEgroundfishMSE/groundfish-MSE

module load gcc/5.1.0        # load the gcc module for compilation
module load R/3.4.0          # load R module

cd groundfish-MSE/           # change directories to groundfish-MSE

Rscript ./processes/runPre.R --vanilla    # Run the runPre.R code

echo "runPre complete"       # Print statement indicating job is done
```
There are new processes going on in runPre.sh that we haven't discussed:
* ```rm -r -f groundfish-MSE/``` deletes the previous groundfish-MSE directory if it already exists

* ```module load git/2.1.3``` loads git to the environment so it can be used

* ```git clone``` clones the groundfish-MSE repository from Git-Hub.  The idea is that if there are multiple people working on the project, the run will only ever use the most recent version that has been uploaded to Git-Hub.  Practically, this means that when you go to run the MSE you must push your changes before submitting the job to the HPCC.  
  * *note:* if you want to change to cloning a particular branch from gitHub use ```git clone -b <branchname> <url>```. For example, if you are working on a branch called *addRickerSR* the line cloning from GitHub might look like:  
    ```
    git clone -b addRickerSR https://samtruesdell:17d3b37aa4080198a25fe421470b97f92af26794@github.com/COCA-NEgroundfishMSE/groundfish-MSE
    ```

* ```module load gcc/5.1.0``` loads gcc into the environment which is needed to compile the TMB catch-at-age model (this occurs in *runPre.R* in a few lines)

* ```cd groundfish-MSE/``` the current directory from which the run was made is one level up from *groundfish-MSE* which now exists if it didn't before.  ```cd``` stands for *change directory* so this command moves into this folder.

* ```Rscript ./processes/runPre.R --vanilla``` runs the runPre.R code.  ```Rscript``` tells the computer to execute the R code.  The ```./``` is necessary to specify that the computer should begin looking in the current directory and ```--vanilla``` means that R should have an ordinary run that doesn't do anything like save extra output.

*runPre.R* essentially just creates results directories and compiles the TMB code.  See the comments in that file for more information.


### runSim.sh
This is the code that actually runs the simulations.

```
#!/bin/bash

#BSUB -W 03:59                # How much time does your job need (HH:MM)
#BSUB -q short                # Which queue
#BSUB -J "runSim[1-25]"       # Job Name (and array size)
#BSUB -R rusage[mem=10000]    # Memory requirements (in MB)
#BSUB -n 1                    # Number of nodes to use
#BSUB -o "./%J.o"             # Specifies name of the output file
#BSUB -e "./%J.e"             # Specifies name of the error file
#BSUB -w 'done(runPre)'       # wait to submit until down with runPre job

cd groundfish-MSE/            # change directories to groundfish-MSE
module load R/3.4.0           # load R module

Rscript ./processes/runSim.R --vanilla       # Run the runSim.R code

echo "runSim complete"        # Print statement indicating job is done
```

Things we haven't yet encountered that show up here:

* ```#BSUB -J "runSim[1-25]"``` runSim is the job name which we've seen before, but [1-25] is new.  This indicates the "array" size -- in other words how many repetitions do you want to run?  [1-50] will be 50, [1-100] will be 100, etc.

* ```#BSUB -w 'done(runPre)'``` ensures that the simulation code does not start before the job named *runPre* is complete.  Clearly this is necessary for us because if the simulations were to start first there would be no *groundfish-MSE* directory to ```cd``` into!  And the TMB model would not be compiled.  For more information and a simple demonstration about how this code works see the file */documentation/hpccUMASS_batchJobs.md*.


### runPost.sh
This code compiles the results of each of the individual simulations and creates plots.

```
#!/bin/bash

#BSUB -W 00:15                    # How much time does your job need (HH:MM)
#BSUB -q short                    # Which queue
#BSUB -J "runPost"                # Job Name
#BSUB -R rusage[mem=10000]        # Memory requirements (in MB)
#BSUB -n 1                        # Number of nodes to use
#BSUB -o "./%J.o"                 # Specifies name of the output file
#BSUB -e "./%J.e"                 # Specifies name of the error file
#BSUB -w 'done(runSim[1-25])'     # wait to submit until down with runSim job

module load R/3.4.0               # load R module
cd groundfish-MSE/                # change directories to groundfish-MSE
Rscript ./processes/runPost.R --vanilla      # Run the runSim.R code

echo "runPost complete"           # Print statement indicating job is done
```

By now we have encountered all the code in *runPost.sh* in other files so there is nothing new.  An important note however is that **when you change the array size in runSim.sh you must also change it in runPost.sh where the script specifies it should wait for the runSim job to complete (**```#BSUB -w 'done(runSim[1-25])'```**)**.  This is easy to forget.

***
### Editing the .sh files on the HPCC
Most changes to the model will be made on local machines and then uploaded to Git-Hub.  However, the four .sh files are not used directly by what is copied from Git-Hub (although there are copies of the files in the *groundfish-MSE* folder for reference).  If you want to edit these files (e.g., to change the number of simulations or possibly the memory allocation) it is useful to be able to do this directly on the HPCC (that way you don't have to re-upload and re-remember to use ```dos2unix```).  If you use WinSCP or MobaXterm for your file transfers you should be able to open the .sh files directly using that environment.  Alternatively, there is an equally easy scenario where you can edit files directly from the HPCC console using the function ```nano```.  This will open up the file inside the console.  For example, after navigating using ```cd``` to the directory that contains the .sh files, the command
```
nano runPost.sh
```
will open up the file and it looks something like
```
#!/bin/bash

#BSUB -W 00:15                    # How much time does your job need (HH:MM)
#BSUB -q short                    # Which queue
#BSUB -J "runPost"                # Job Name
#BSUB -R rusage[mem=10000]        # Memory requirements (in MB)
#BSUB -n 1                        # Number of nodes to use
#BSUB -o "./%J.o"                 # Specifies name of the output file
#BSUB -e "./%J.e"                 # Specifies name of the error file
#BSUB -w 'done(runSim[1-25])'     # wait to submit until down with runSim job

module load R/3.4.0               # load R module
cd groundfish-MSE/                # change directories to groundfish-MSE
Rscript ./processes/runPost.R --vanilla      # Run the runSim.R code

echo "runPost complete"           # Print statement indicating job is done

^G Get Help   ^O WriteOut   ^R Read File   ^Y Prev Page   ^K Cut  Text    ^C Cur Pos
^X Exit       ^J Justify    ^W Where Is    ^V Next Page   ^U UnCut Text   ^T To Spell
```
Now you can navigate with the arrow keys and type in any changes you want to make to the file (e.g., changing the number of simulations).  When you are done, click CTRL-X to exit (note the shortcuts at the bottom of the page).  If you have made a change it will ask you if you want to save and if so you can type ```Y``` and hit Enter.

***

### Running the MSE
Running the MSE is straightforward once everything is in place (e.g., you have the libraries loaded, you've uploaded the four .sh files, you've settled on a number of simulations in both the *runSim.sh* and *runPost.sh* scripts, you've converted the .sh files to Unix/Linux format if necessary, etc.).  All you need to do is enter ```bsub < run.sh```.  You will get output indicating that your job has been submitted to the queue

```
[st12d@ghpcc06 COCA_HPCC]$ bsub < run.sh
Job <9049872> is submitted to queue <short>.
```

and you wait for it to complete.  You can check the status using the command ```bjobs``` (you can use this no matter what HPCC directory you are in).  When the job is complete you will have four new files with the extension .o, four new files with the extension .e and there will be .Rdata files and plots in the *Results* directory.

***

### Notes

* On my local linux Ubuntu machine I've found I can't install R's tidyverse library (necessary for the planB assessment approach written by C Legault) under the default conditions.  I had to first update the system.  Based on a web search I found packages to add to the linux system: ```sudo apt-get install r-cran-curl r-cran-openssl r-cran-xml2``` and after I made these changes I could install tidyverse.

[Return to Wiki Home](https://github.com/thefaylab/groundfish-MSE/wiki)
