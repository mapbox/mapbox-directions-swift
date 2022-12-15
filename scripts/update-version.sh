#!/usr/bin/env bash

set -e
set -o pipefail
set -u

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

if [ $# -eq 0 ]; then
    echo "Usage: v<semantic version>"
    exit 1
fi

SEM_VERSION=$1
SEM_VERSION=${SEM_VERSION/#v}
SHORT_VERSION=${SEM_VERSION%-*}
MINOR_VERSION=${SEM_VERSION%.*}
YEAR=$(date '+%Y')

step "Version ${SEM_VERSION}"

step "Updating Xcode targets to version ${SHORT_VERSION}…"

xcrun agvtool bump -all
xcrun agvtool new-marketing-version "${SHORT_VERSION}"

step "Updating CocoaPods podspecs to version ${SEM_VERSION}…"

find . -type f -name '*.podspec' -exec sed -i '' "s/^ *s.version *=.*$/  s.version      = \"${SEM_VERSION}\"/" {} +

step "Updating changelog to version ${SHORT_VERSION}…"

sed -i '' -E "s/## *master/## ${SHORT_VERSION}/g" CHANGELOG.md

# Skip updating the installation instructions for patch releases or prereleases.
if [[ $SHORT_VERSION == $SEM_VERSION && $SHORT_VERSION == *.0 ]]; then
    step "Updating readmes to version ${SEM_VERSION}…"
    sed -i '' -E "s/~> *[^']+/~> ${MINOR_VERSION}/g; s/.git\", from: \"*[^\"]+/.git\", from: \"${SEM_VERSION}/g" README.md
elif [[ $SHORT_VERSION != $SEM_VERSION ]]; then
    step "Updating readmes to version ${SEM_VERSION}…"
    sed -i '' -E "s/:tag => 'v[^']+'/:tag => 'v${SEM_VERSION}'/g; s/'MapboxDirections-pre', *'[^']+'/'MapboxDirections-pre', '${SEM_VERSION}'/g; s/\"mapbox\/mapbox-directions-swift\" \"v[^\"]+\"/\"mapbox\/mapbox-directions-swift\" \"v${SEM_VERSION}\"/g; s/\.exact\\(\"*[^\"]+/.exact(\"${SEM_VERSION}/g" README.md
fi

step "Updating copyright year to ${YEAR}…"

sed -i '' -E "s/© ([0-9]{4})[–-][0-9]{4}/© \\1–${YEAR}/g" LICENSE.md docs/jazzy.yml Sources/MapboxDirections/Info.plist

# Bumping baseline if this is not alpha or beta release. During alpha/beta it is allowed to break the API that was added during alpha-beta cycle.
if [[ $1 != *alpha* && $1 != *beta* ]]; then
    step "Bumping API baseline"
    ./scripts/update-baseline.sh $1
fi

BRANCH_NAME="update-version-${SEM_VERSION}"
git checkout -b $BRANCH_NAME
git add .
git commit -m "Update version ${SEM_VERSION}"
git push origin $BRANCH_NAME

if [[ $SEM_VERSION =~ "alpha" || $SEM_VERSION =~ "beta" ]]; then
    BASE_BRANCH_NAME="main"
  else
    MAJOR=${SEM_VERSION%%.*}
    MINOR_TMP=${SEM_VERSION#*.}
    MINOR=${MINOR_TMP%%.*}
    BASE_BRANCH_NAME="release-v${MAJOR}.${MINOR}"
fi

brew install gh
GITHUB_TOKEN=$GITHUB_WRITER_TOKEN gh pr create \
    --title "Release v${SEM_VERSION}" \
    --body "Bump version to ${SEM_VERSION}" \
    --base $BASE_BRANCH_NAME \
    --head $BRANCH_NAME
