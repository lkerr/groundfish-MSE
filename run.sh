echo "Update code to current version on GitHub"

cd groundfish-MSE   # navigate to the repository directory
git fetch --depth=1 origin NEFMC_Risk_Policy   # fetch the current version of branch in repository with out merging remote and local files
git reset --hard origin/NEFMC_Risk_Policy   # force local tracked files to match the remote, discarding local modifications and commits
git clean -fdx   # this line would delete all untracked files (if including x, will also delete ignored files; wihtout x, ignored files remain)

echo "Done"   # directory should now look like a clean, freshly cloned version of the branch

# echo "Run Control file"
bash control.sh   # run the script