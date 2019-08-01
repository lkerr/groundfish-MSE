

# MSE File Structure
#### Sam Truesdell (struesdell@gmri.org)

### This document describes the file structure for groundfish-MSE on GitHub -- and on your local machine once you have cloned the repository.


#### General Framework
The overall approach to the MSE is to attempt to have the code be as compartmentalized as possible. In general this means having lots of functions. One of the first things the MSE simulation code does is load in all the functions in the groundfish-MSE/functions folder. The way the code is written, some actions (e.g., setting up containers to hold the results) need to occur in the global environment. These are *processes* here and are located in the groundfish-MSE/processes folder. When you are making changes to the code, you will typically be working in either the processes or the functions folders.

#### Folders

* **ShinyApp**: Work to-date on the shiny application that will eventually be used to communicate MSE results to stakeholders.

* **assessment**: Folder that holds assessment models and related material. The simulation does call files in this folder.

* **data**: Data related to the project. Folder subdivided into processes (i.e., .Rdata files) and raw data.  Many preliminary/exploratory analyses use data from this folder, but for everyday runs this folder has limited use save holding the temperature projection data.

* **documentation**: You are here! Files attempting to document both the MSE methods and use on a local machine or the HPCC.

* **functions**: All the functions that are used by the MSE. Folder further divided into functions related to the assessment process, management procedures, plotting and population dynamics. These subdivisions are only for organization.

* **modelParameters**: All files that deal with paramaterization of the current model run are found in this folder.  the file set_om_parameters_global.R contains the super-stock level operating model parameters (e.g., things like time-frames and temperature information to use). mproc.txt governs the management procedues that will be compared during the run and mprocTest.txt is a version of this file used for testing. The sub-folder **stockParameters** contains the stock-level information for each stock.  All stocks that are contained in this folder will be included in the run.

* **preprocessing**: Processing some of the raw data into .Rdata files to be used in some preliminary/exploratory analyses. Files in this folder are mostly unused.

* **processes**: Most of the files in this folder are run in the global environment of the MSE. This includes runSim.R which is the overall control file. It also contains runSetup.R which is the file that parameterizes the MSE.

* **scratch**: Some analyses that are saved because at some point one might return to them. Generally a scratchpad to store exploratory analyses.

#### Files

* **.gitignore**: A file important to have on your local machine. Here you list anything that you want git to ignore when it searches for changes to files. Essentially anything that is not a text file or something like it should be ignored and not uploaded because we don't need to be tracking changes to those types of files.

* **LICENSE**: Not important.

* **README.md**: Describes where to find the documentation.

* **run.sh/runNoGit.sh/runPost.sh/runPre.sh/runSim.sh**: Shell files that are used to actually run the MSE on the HPCC. These need to be accessible because if you run the MSE on the HPCC you need to have these files uploaded to your HPCC account separately from just cloning from GitHub (see [hpccUMASS_runMSE.md](hpccUMASS_runMSE.md)).

[Return to Wiki Home](https://github.com/thefaylab/groundfish-MSE/wiki)
