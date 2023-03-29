#!/bin/bash

[ -z "$1" ] && echo "ERROR: No release name was given as argument." && exit 1

relname=releases/$1

echo ">>>> Making release: $relname"

[[ $(git tag -l "$relname") ]] && echo "ERROR: Tag $relname already exists!" && exit 1

echo ">>>> Switching to master branch"

git checkout master && git pull origin master

[[ $(git diff origin/master) ]] && git --no-pager diff origin/master && \
  echo "ERROR: Local master is different from origin/master! (see above)" && exit 1

#echo ">>>> Checking for clean master"
#[[ ! -z "$(git status --porcelain)" ]] && echo "ERROR: Working copy of master is not clean." && exit 1

echo ">>> Creating local tag"
git tag -a $relname

echo ">>> Pushing tag to github"
git push origin $relname

echo ">>> Done!"

echo "Check here for release workflow: https://github.com/JeremyMcCormick/maven-test-project/actions"
