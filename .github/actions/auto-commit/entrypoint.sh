#!/bin/bash
set -e

BRANCH=develop

git config --global user.name 'autobot'
git config --global user.email 'autobot@leetserve.com'
git checkout "${BRANCH}"
git pull
git add -A && git commit -m 'bumpver' --allow-empty
git push -u origin "${BRANCH}"