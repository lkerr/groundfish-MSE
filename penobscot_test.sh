########## Generate an ssh keypair on the HPC to access private GitHub repositories
# open an on demand terminal on Penobscot: login1.acg.maine.edu > Clusters > Penobscot Cluster Shell Access
ssh-keygen -t ed25519 -C "your_email@example.com"
# press enter to accept default file location: ~/.ssh/id_ed25519
# pick a passphrase or press enter to leave it empty (no passphrase, less secure)
# passphrase (or enter) will need to be entered twice
# print the public key to the terminal
cat ~/.ssh/id_ed25519.pub
# copy the full contents and add them to your GitHub account:
# Github > settings> SSH and GPG keys>New SSH key>
# Name the new key with something like “Penobscot Cluster, UMaine”
# Paste the public key into the text box and save (will need to enter your password)
# Can test connection with
ssh -T git@github.com

########## Remove and reclone the Risk Policy branch
# open an on demand terminal on Penobscot: login1.acg.maine.edu > Clusters > Penobscot Cluster Shell Access
# navigate to directory of interest (one level up from code repository to be cloned)
cd NEFMC_Risk_Policy

# remove old code directory
rm -r -f groundfish-MSE/

# clone the current version of code repository --single-branch limits to only target branch and --depth 1 does not clone the full version history
# change <NEFMC_Risk_Policy> to the branch name you want
git clone -b NEFMC_Risk_Policy --single-branch --depth 1 git@github.com:lkerr/groundfish-MSE.git

# Even with single-branch and depth 1 this took 15 min for NEFMC_Risk_Policy.
# We should consider whether pulling is sufficient instead of deleting and re-cloning. Maybe with:
git fetch --depth=1 origin NEFMC_Risk_Policy # fetches current version of branch in repository with out merging remote and local files
git reset --hard origin/NEFMC_Risk_Policy # forces local tracked files to match the remote, discarding local modifications and commits
git clean -fd # this line would delete all untracked files (so results?)

# Then can open an interactive RStudio session, open ~/processes/runSim.R and try running the simulation

