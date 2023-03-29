#!/bin/bash

[ -z "$1" ] && echo "ERROR: No release name was given as argument." && exit 1

relname=releases/$1

echo ">>>> Making release: $relname"

if [[ $(git tag -l "$relname") ]]; then echo "ERROR: Tag $relname already exists." && exit 1; fi

echo ">>>> Switching to master branch"

git checkout master

#echo ">>> Checking out master branch ..."
#git stash; git fetch origin; git reset --hard origin/master

echo ">>>> Pulling master from origin"
git pull origin master

echo ">>>> Checking for clean master"
if [[ ! -z "$(git status --porcelain)" ]]; then echo "ERROR: Working copy of master is not clean." && exit 1; fi

echo ">>> Creating local tag"
git tag -a $relname

echo ">>> Pushing tag to github"
git push origin $relname

echo ">>> Done!"
