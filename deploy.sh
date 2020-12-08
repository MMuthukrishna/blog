#!/usr/bin/env sh

# abort on errors
set -e

hugo --minify

# navigate into the build output directory
cd dist

# if you are deploying to a custom domain
# echo 'www.example.com' > CNAME

git init
git add -A
#git commit -m 'deploy'
git commit --amend --no-edit -a

git push -f git@github.com:mmuthukrishna/blog.git master:gh-pages

cd -
