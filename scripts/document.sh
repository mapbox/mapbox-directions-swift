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
RELEASE_VERSION=$( echo ${SHORT_VERSION} | sed -e 's/-.*//' )
MINOR_VERSION=$( echo ${SHORT_VERSION} | grep -Eo '^\d+\.\d+' )

DEFAULT_THEME="docs/theme"
THEME=${JAZZY_THEME:-$DEFAULT_THEME}

BASE_URL="https://docs.mapbox.com/ios"

rm -rf ${OUTPUT}
mkdir -p ${OUTPUT}

#cp -r docs/img "${OUTPUT}"

rm -rf /tmp/mbdirections
mkdir -p /tmp/mbdirections/
README=/tmp/mbdirections/README.md
cp docs/cover.md "${README}"
perl -pi -e "s/\\$\\{MINOR_VERSION\\}/${MINOR_VERSION}/" "${README}"
# http://stackoverflow.com/a/4858011/4585461
echo "## Changes in version ${RELEASE_VERSION}" >> "${README}"
sed -n -e '/^## /{' -e ':a' -e 'n' -e '/^## /q' -e 'p' -e 'ba' -e '}' CHANGELOG.md >> "${README}"

jazzy \
    --config docs/jazzy.yml \
    --sdk iphonesimulator \
    --module-version ${SHORT_VERSION} \
    --github-file-prefix "https://github.com/mapbox/mapbox-directions-swift/tree/${BRANCH}" \
    --readme ${README} \
    --documentation="docs/guides/*.md" \
    --root-url "${BASE_URL}/directions/api/${RELEASE_VERSION}/" \
    --theme ${THEME} \
    --output ${OUTPUT} \
    --build-tool-arguments CODE_SIGN_IDENTITY=,CODE_SIGNING_REQUIRED=NO,CODE_SIGNING_ALLOWED=NO

REPLACE_REGEXP='s/MapboxDirections\s+(Docs|Reference)/Mapbox Directions for Swift $1/, '

find ${OUTPUT} -name *.html -exec \
    perl -pi -e "$REPLACE_REGEXP" {} \;


echo $SHORT_VERSION > $OUTPUT/latest_version
