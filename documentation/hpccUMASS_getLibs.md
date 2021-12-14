# Installing R libraries on your UMASS HPCC account
#### (Sam Truesdell struesdell@gmri.org)

<br>
Running the MSE requires some specific R libraries.  Similarly to when you run install.packages() on your local machine we need to do the same in order to run them on the remote server. It is probably possible to include this step automatically during each run by testing for library availability and installing any that are missing but that is not currently implemented. However, you can follow these instructions once and you don't have to worry about it later. If these instructions do not work (sometimes the HPCC does not cooperate), then email Mackenzie (mmazur@gmri.org) for a folder of the R libraries that you can load onto your HPCC account. 

***

### Steps for installing libraries

1. Log in to your HPCC account.  You will get a prompt that looks something like
   ```
   [st12d@ghpcc06 ~]$
   ```
     except it won't start with st12d it will start with your username.

2. Load gcc. When R packages are installed they need to be compiled in order to run -- gcc is in charge of this step.  gcc is not automatically available however -- you have to tell the HPCC that you are going to want to use it.  Load it using
   ```
   [st12d@ghpcc06 ~]$ module load gcc/5.1.0
   ```
   and you will get an output something like
   ```
   [st12d@ghpcc06 ~]$ module load gcc/5.1.0
   gcc 5.1.0 is located under /share/pkg/gcc/5.1.0
   ```
3. Next load R  
Just like gcc, you have to tell the HPCC that you are going to want to use R before you are able to open it.
   ```
   module load R/3.4.0
   ```
   the output looks something like
   ```
   [st12d@ghpcc06 ~]$ module load R/3.4.0
   R 3.4.0 is located under /share/pkg/R/3.4.0
   When compiling modules for this, be sure to load gcc/5.1.0
   ```
   It wants to make sure we've loaded gcc/5.1.0 in case we want to install packages -- good news: we  did that in step 2!

4. Open R by typing R in the console and hitting Enter
   ```
   [st12d@ghpcc06 ~]$ R
   ```
   Now even though the screen hasn't changed much (it's not like opening a program on your local machine) you are now working in R:

     ```
     [st12d@ghpcc06 ~]$ R

     R version 3.4.0 Patched (2017-05-16 r72684) -- "You Stupid Darkness"
     Copyright (C) 2017 The R Foundation for Statistical Computing
     Platform: x86_64-pc-linux-gnu (64-bit)

     R is free software and comes with ABSOLUTELY NO WARRANTY.
     You are welcome to redistribute it under certain conditions.
     Type 'license()' or 'licence()' for distribution details.

       Natural language support but running in an English locale

     R is a collaborative project with many contributors.
     Type 'contributors()' for more information and
     'citation()' on how to cite R or R packages in publications.

     Type 'demo()' for some demos, 'help()' for on-line help, or
     'help.start()' for an HTML browser interface to help.
     Type 'q()' to quit R.
     ```
     If you ever want to exit R so you can get back to the HPCC console, just type
     ```
     > q()
     ```
     hit enter and you will exit.

5. Now we will install the packages.  The only tricky step here is is that we have to tell R where we want the packages to be installed.  Note that this will depend on how you have set up your HPCC account.  The trick is that the program assumes that you have a folder called **Rlib** and that it is a level **up** from the directory you are running the MSE from.  If you do not already have this folder R will automatically create it for you.

   ```
   > install.packages(c('gmm', 'mvtnorm', 'tmvtnorm', 'expm',
                        'msm', 'Matrix', 'TMB', 'abind',
                        'forcats', 'readr', 'tidyverse'),
                      lib='~/COCA_HPCC/Rlib/',
                      repos='http://cran.us.r-project.org')
   ```
The **~** in the function call under ```lib='~/COCA_HPCC/Rlib/``` refers to your home directory on the HPCC.  The folder I have in the next level from my home directory is called **COCA_HPCC**.  I already have a folder called **groundfish-MSE** (you'll have that after you run the code -- see **hpccUMASS_runMSE.md** when you're done here) and the folders that are in my home directory look something like:

*  ~/COCA_HPCC/groundfish-MSE
*  ~/COCA_HPCC/Rlib
    
Your directory structure may look different -- for example if this is the first time you are logging on to the HPCC you wouldn't have a folder called **COCA_HPCC**.  If your account has a different file structure you can't copy the ```install.packages()``` code directly -- you will need to edit the path for **lib** and replace **COCA_HPCC** with the name of your folder. You will need to create a folder **Rlib** that will hold the libraries. You can do this with the command **mkdir Rlib** from the console or you can create the folder with your SFTP software (e.g., WINSCP). What matters most is that the **Rlib** folder needs to be at the same structural level from where **groundfish-MSE** will be when you download it (as it is in my structure above). If you are agnostic as to your file structure you can just make it look like mine above (recall you don't need to explicitly create a groundfish-MSE folder as that will be created automatically). See the end of this document if you want a little more information.

   Once you hit enter R will begin installing libraries and you will see things like:
   ```
   > install.packages(c('gmm', 'mvtnorm', 'tmvtnorm', 'expm', 'msm', 'Matrix', 'TMB', 'abind', 'forcats', 'readr', 'tidyverse'), lib='~/COCA_HPCC/Rlibtrying URL 'http://cran.us.r-project.org/src/contrib/gmm_1.6-2.tar.gz'
   Content type 'application/x-gzip' length 1007355 bytes (983 KB)
   ==================================================
   downloaded 983 KB

   trying URL 'http://cran.us.r-project.org/src/contrib/mvtnorm_1.0-8.tar.gz'
     Content type 'application/x-gzip' length 159539 bytes (155 KB)
     ==================================================
     downloaded 155 KB

     trying URL 'http://cran.us.r-project.org/src/contrib/tmvtnorm_1.4-10.tar.gz'
   Content type 'application/x-gzip' length 248470 bytes (242 KB)
   ==================================================
   downloaded 242 KB
   ```
   This will go on and on, probably for 10 or 15 minutes, maybe longer.  But you can let it go and take a break -- you are done installing packages and are ready to run the MSE!
***
*More information on the file structure in Step 5*  
More specifically, the code in the program **groundfish-MSE/processes/loadLibs.R** specifies the location of the libraries using ```require(library, lib.loc='../Rlib/')```.  ```require()``` works like ```library()```. The ```../Rlib/``` tells R to go up one level from the directory from which the call was made to look for the directory **Rlib** which is where it will find the packages.  The reason the packages have to be a level up from the rest of the material (i.e., the groundfish-MSE directory) is that all the material is re-loaded from Git-Hub whenever the model is run but the packages are not part of the Git-Hub material.  In other words, if the packages were within the groundfish-MSE directory they would be deleted.

[Return to Wiki Home](https://github.com/thefaylab/groundfish-MSE/wiki)
