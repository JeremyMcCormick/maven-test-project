#!/bin/bash

# This only needs to be done once!

# From:
# https://www.lorenzobettini.it/2020/01/publishing-a-maven-site-to-github-pages/

git checkout --orphan gh-pages 
rm .git/index ; git clean -fdx 
echo "It works" > index.html 
git add . && git commit -m "initial site content" && git push origin gh-pages
