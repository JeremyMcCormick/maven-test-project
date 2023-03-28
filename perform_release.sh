#!/bin/sh

relname=$1
[ -z "$relname" ] && echo "ERROR: No release name was given as argument." && exit 1

echo "Making release: $relname"

echo "Checking out master branch ..."
#git checkout master && git pull origin master
git stash; git fetch origin; git reset --hard origin/master

echo "Creating local tag ..."
git tag -a releases/$relname

echo "Pushing tag to github ..."
git push origin releases/$relname

echo "Done!"
