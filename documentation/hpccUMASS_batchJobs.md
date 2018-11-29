
# Running scripts in sequence using batch jobs
(Sam Truesdell struesdell@gmri.org)

Sometimes it is useful to submit multiple jobs at once but also ensure that they will run in a particular order. For example, say you want to repeat a simulation 1000 times and then plot the results. You can write a program that (1) sends an array job (an array job being a set of identical scripts such as simulation repetitions); and (2) waits until the entire array is finished and then reads in the results from the 1000 simulations and makes some plots. This is similar to the example above except it emphasizes that you can submit several jobs at once and that you can easily specify an order of execution for the scripts.

This is probably best described by an example. Below are three files: a control script, an array script and a completion script. You can try the procedure described below yourself by copying the three scripts into blank text files (with names matching the names in this example) and uploading them to your directory on the GHPCC. Don't forget to change the extensions to **.sh** (stands for shell file).

####Control script
script name: **runsleep.sh**
action: submits the two other scripts to the queue.
```
#!/bin/bash

#BSUB -W 00:15                   # How much time does your job need (HH:MM)
#BSUB -q short                   # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "runsleep"              # Job Name
#BSUB -R rusage[mem=10000] 		 # Specify memory usage (needlessly high for this job)
#BSUB -n 1						 # Number of processors to use

#BSUB -o "./%J.o"				 # name for the output file
#BSUB -e "./%J.e"				 # name for the error file

bsub < sleep100.sh				 # submit the sleep100 shell file
bsub < echocomplete.sh			 # submit the echocomplete shell file
```

####Array script
script name: **sleep100.sh**
action: executes the primary code (which in this case is simply sleeping). Pay special attention to the bracketed suffix on the name below ```sleep100[1-3]```. This indicates that an array of 3 identical jobs should be submitted to run in parallel. If you were actually using this for your research this could entail submitting your individual simulation runs.
```
#!/bin/bash

#BSUB -W 00:15              # How much time does your job need (HH:MM)
#BSUB -q short              # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "sleep100[1-3]"    # Job Name (and parallel array specification)
#BSUB -R rusage[mem=10000]  # Specify memory usage (needlessly high for this job)
#BSUB -n 1                  # Number of processors to use

#BSUB -o "./%J.o" 			# name for the output file
#BSUB -e "./%J.e" 			# name for the error file

sleep 100                   # sleep for 100 seconds (this is the operative code and
							# would otherwise be something like Rscript ./runSim.R --vanilla)

echo "sleep100.sh: sleep complete"  # print something saying the job is done
```

####Completion script
script name: **echocomplete.sh**
action: prints text so you know that the job has run to completion.
If you were using something similar for your research, this script would be doing something like reading in the results of the simulations and plotting them but here we're just reporting that the job is done. The important thing here is the command ```#BSUB -w 'done(sleep100[1-3])'```. This specifies that this script should wait until the **sleep100.sh** script is complete before executing its code.
```
#!/bin/bash

#BSUB -W 00:15                  # How much time does your job need (HH:MM)
#BSUB -q short                  # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "echocomplete"         # Job Name
#BSUB -R rusage[mem=10000]      # Specify memory usage (needlessly high for this job)
#BSUB -n 1                      # Number of processors to use

#BSUB -o "./%J.o"               # name for the output file
#BSUB -e "./%J.e"               # name for the error file

#BSUB -w 'done(sleep100[1-3])'  # Operative line for dependencies.
								# Wait until done with sleep100 job.

echo "echocomplete.sh: job complete"  # print a line indicating the job is finished
```
### Convert files to a readable format
Once these three files have been uploaded to your directory they have to be converted to a format that can be read properly by the GHPCC which runs using Linux. Line breaks differ between Windows and Linux/Unix so we have to specify a conversion. Once you have uploaded the files, navigate to the directory using the command line and type these commands:
```
dos2unix runsleep.sh
dos2unix sleep100.sh
dos2unix echocomplete.sh
```
If entered correctly you should get the message ```dos2unix: converting file <filename here>.sh to UNIX format ...``` after each entry. Now the files can be read properly.

### Run the entire job

As long as you have navigated to the directory where you stored these three files, you can submit the **runsleep.sh** file using ```bsub < runsleep.sh``` (note the slightly different syntax from the previous bsub version above -- you need the **<**). The whole job should take a couple of minutes to run (recall we told the program to sleep for 100 seconds).

As the job runs you can check the progress using ```bjobs```. If you keep typing ```bjobs``` into the console you should be able to see the progression of:

\noindent1. **runsleep.sh** submitted and pending;

JOBID  |USER |STAT   |QUEUE   |FROM_HOST |EXEC_HOST|JOB_NAME|SUBMIT_TIME
-----  |---- |----   |-----   |--------- |---------|--------|-----------
1001|userID|PEND   |short   |         |         |runsleep|Oct 2 09:33


\noindent2. **runsleep.sh** running and causing three versions of **sleep100.sh** to be submitted (and pending);

JOBID|USER|STAT|QUEUE|FROM_HOST |EXEC_HOST|JOB_NAME  |SUBMIT_TIME
-----|----|----|-----|--------- |---------|--------  |-----------
1001|userID|RUN |short|      |         |runsleep  |Oct  2 09:33
1002|userID|PEND|short|      |         |*eep100[1]|Oct  2 09:33
1002|userID|PEND|short|      |         |*eep100[2]|Oct  2 09:33
1002|userID|PEND|short|      |         |*eep100[3]|Oct  2 09:33


\noindent3. **echocomplete.sh** waiting in the queue without executing (i.e., pending) until all of the **sleep100.sh** separate runs are complete; and

JOBID  | USER | STAT| QUEUE| FROM_HOST| EXEC_HOST| JOB_NAME  | SUBMIT_TIME
-----  | ---- | ----| -----| ---------| ---------| --------  | -----------
1002| userID| RUN | short|    |          | *eep100[1]| Oct 2 09:33
1002| userID| RUN | short|    |          | *eep100[3]| Oct 2 09:33
1002| userID| RUN | short|    |          | *eep100[2]| Oct 2 09:33
1003| userID| PEND| short|    |          | *ocomplete| Oct 2 09:33

\noindent4. **echocomplete.sh** running.

JOBID  |USER |STAT|QUEUE|FROM_HOST|EXEC_HOST|JOB_NAME  |SUBMIT_TIME
-------|-----|----|-----|---------|---------|----------|-----------
1003|userID|RUN |short|        |         |*ocomplete|Oct  2 09:33

You can  check the results by opening the **.o** and **.e** report files (they will appear in the directory) through your interface program or in the console using the command ```cat```. For example, to check the output from job 1003 you could type ```cat 1003.o``` (note: your job IDs will be longer than 4 digits). Below is some example output. Note that ```echocomplete.sh: job complete``` is what we told it to print in the file **echocompte.sh**. This is followed by other information about the job, including the script that was submitted.

```
echocomplete.sh: job complete

------------------------------------------------------------
[Some job information here]

Your job looked like:
------------------------------------------------------------
# LSBATCH: User input
#!/bin/bash

#BSUB -W 00:15                  # How much time does your job need (HH:MM)
#BSUB -q short                  # Which queue {short, long, parallel, GPU, interactive}
#BSUB -J "echocomplete"         # Job Name
#BSUB -R rusage[mem=10000]      # Specify memory usage (needlessly high for this job)
#BSUB -n 1                      # Number of processors to use

#BSUB -o "./%J.o"               # name for the output file
#BSUB -e "./%J.e"               # name for the error file

#BSUB -w 'done(sleep100[1-3])'  # Operative line for dependencies.
                                # Wait until done with sleep100 job.

echo "echocomplete.sh: job complete"  # print a line indicating the job is finished
------------------------------------------------------------

Successfully completed.

Resource usage summary:

    CPU time :                                   0.18 sec.
    Max Memory :                                 -
    Average Memory :                             -
    Total Requested Memory :                     10000.00 MB
    Delta Memory :                               -
    Max Swap :                                   -
    Max Processes :                              -
    Max Threads :                                -
    Run time :                                   1 sec.
    Turnaround time :                            103 sec.

The output (if any) is above this job summary.



PS:

Read file <./1003.e> for stderr output of this job.
```

###Notes
* If you have an array submission like we do here and you want to alter the number of parallel procedures (i.e., the [1-3] suffix) you need to change the syntax in two places: (1) the naming in the array script (i.e., change the [1-3] in ```sleep100[1-3]``` to ```sleep100[1-5]``` for 5 repetitions); and (2) in the completion script you would change ```'done(sleep100[1-3])'``` to ```'done(sleep100[1-5])'```.

* Any error messages from your code will be stored in the files with the extension **.e**. Any output will be stored in the files with extension **.o**. You can access them using the ```cat``` command in the console or through your file interface program.

* If you are designing simulations (e.g., in R) you want to do it so that you can easily run in parallel. The outer loop should indicate the simulations so you can easily change your number of simulations. If you want to run 1000 simulations in total you could do something like change the number of repetitions per script to 10 and run a job with an array of 100.

* I tend to commit plenty of mistakes as I'm working on this stuff. With the ```-w 'done()'``` command this means that I sometimes have jobs in my queue that will never run. The command ```qdel JOBID``` (you can find the job ID using the ```bjobs``` command) will delete the specified job from your queue.

* If you are like me you may find this perplexing. Feel free to e-mail me at struesdell@gmri.org. I'm not a computer programmer and I only know what I've found necessary for my work but I might be able to help with some basics!

* I've found UMASS GHPCC support to be very responsive -- you can e-mail them at hpcc-support@umassmed.edu. They helped me figure out ```-w 'done()'``` and they provided me this example.

***
