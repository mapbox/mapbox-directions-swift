#!/usr/bin/env bash

set -e
set -o pipefail
set -u

if [ -z `which jazzy` ]; then
    echo "Installing jazzy…"
    gem install jazzy
    if [ -z `which jazzy` ]; then
        echo "Unable to install jazzy. See https://github.com/mapbox/mapbox-gl-native/blob/master/platform/ios/INSTALL.md"
        exit 1
    fi
fi


OUTPUT=${OUTPUT:-documentation}

BRANCH=$( git describe --tags --match=v*.*.* --abbrev=0 )
SHORT_VERSION=$( echo ${BRANCH} | sed 's/^v//' )
RELEASE_VERSION=$( echo ${SHORT_VERSION} | sed -e 's/^v//' -e 's/-.*//' )

rm -rf ${OUTPUT}
mkdir -p ${OUTPUT}

#cp -r docs/img "${OUTPUT}"

DEFAULT_THEME="docs/theme"
THEME=${JAZZY_THEME:-$DEFAULT_THEME}

jazzy \
    --podspec MapboxDirections.swift.podspec \
    --config docs/jazzy.yml \
    --sdk iphonesimulator \
    --module-version ${SHORT_VERSION} \
    --github-file-prefix "https://github.com/mapbox/MapboxDirections.swift/tree/${BRANCH}" \
    --documentation=docs/guides/*.md \
    --root-url "https://mapbox.github.io/mapbox-navigation-ios/directions/${RELEASE_VERSION}/" \
    --theme ${THEME} \
    --output ${OUTPUT}

find ${OUTPUT} -name *.html -exec \
    perl -pi -e 's/BRANDLESS_DOCSET_TITLE/Directions.swift $1/, s/MapboxDirections.swift\s+(Docs|Reference)/MapboxDirections.swift $1/' {} \;
