#!/usr/bin/env bash

set -e
set -o pipefail
set -u

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

OUTPUT="/tmp/`uuidgen`"
RELEASE_BRANCH=${1:-master}
VERSION=${1}
FOLDER=${VERSION:1} # remove first character from VERSION (v)

step "Updating mapbox-directions-swift repository…"
git fetch --depth=1 --prune
git fetch --tags
git checkout $RELEASE_BRANCH

git checkout $VERSION

step "Installing dependencies…"
carthage bootstrap --cache-builds

step "Updating jazzy…"
gem install jazzy

step "Generating new docs for ${VERSION}…"
OUTPUT=${OUTPUT} scripts/document.sh

step "Moving new docs folder to ./$FOLDER"
rm -rf "./$FOLDER"
mkdir -p "./$FOLDER"
mv -v $OUTPUT/* "./$FOLDER"

step "Switching branch to publisher-production"
git checkout origin/publisher-production
step "Committing API docs for $VERSION"
git add "./$FOLDER"
git commit -m "[directions] Add Mapbox Directions for Swift API docs for $VERSION [ci skip]" --no-verify

step "Finished updating documentation"
