#! /bin/bash
# Location of the git folder collection
mygitfolder=~/tank/org_roam_files

# Loop through all folders and place the names in an array
git_folders=()

# Loop through the array and run the commands needed to automaticly push a repo to github,
# git add, commit, push(IF commit executed sucsessfully meaning it was something to commit in that folder) 
   cd "$mygitfolder"; printf "\n\nChecking the $folder repo "
   git stash && git pull --rebase && git stash pop


