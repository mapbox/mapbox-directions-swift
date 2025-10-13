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
FOLDER=${VERSION:1} # removes first character from VERSION (v)

step "Updating mapbox-directions-swift repository…"
git fetch --tags
git checkout $RELEASE_BRANCH

git checkout $VERSION

step "Installing dependencies…"

carthage checkout
# Workaround for OHHTTPStubs not supporting Xcode 14.3+
sed -i '' 's/MACOSX_DEPLOYMENT_TARGET = 10.9/MACOSX_DEPLOYMENT_TARGET = 10.13/g' Carthage/Checkouts/OHHTTPStubs/OHHTTPStubs.xcodeproj/project.pbxproj
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 8.0/IPHONEOS_DEPLOYMENT_TARGET = 12.0/g' Carthage/Checkouts/OHHTTPStubs/OHHTTPStubs.xcodeproj/project.pbxproj
carthage build --platform iOS --cache-builds --configuration Release --use-xcframeworks

step "Updating jazzy…"
bundle install

step "Generating new docs for ${VERSION}…"
OUTPUT=${OUTPUT} scripts/document.sh

step "Moving new docs folder to ./$FOLDER"
rm -rf "./$FOLDER"
mkdir -p "./$FOLDER"
mv -v $OUTPUT/* "./$FOLDER"

step "Switching branch to publisher-production"
git checkout Gemfile.lock
git checkout origin/publisher-production

step "Committing API docs for $VERSION"
git add "./$FOLDER"
git commit -m "Add $VERSION docs [ci skip]" --no-verify

step "Creating new branch docs-${VERSION}"
git checkout -b "docs-${VERSION}"

step "Finished updating documentation"
