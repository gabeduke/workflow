#!/bin/bash
set -e

BRANCH=${1:-develop}

git config --global user.name 'autobot'
git config --global user.email 'autobot@leetserve.com'
git add ${2:-.release} && git commit -m ${3:-'default commit message'} --allow-empty
git push -u origin "${BRANCH}"
