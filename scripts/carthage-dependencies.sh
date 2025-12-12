#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <platform> <configuration>"
    echo "Example: $0 all Debug"
    echo "Example: $0 iOS Release"
    exit 1
fi

PLATFORM=$1
CONFIGURATION=$2

carthage checkout
# Workaround for OHHTTPStubs not supporting Xcode 14.3+
sed -i '' 's/MACOSX_DEPLOYMENT_TARGET = 10.9/MACOSX_DEPLOYMENT_TARGET = 10.13/g' Carthage/Checkouts/OHHTTPStubs/OHHTTPStubs.xcodeproj/project.pbxproj
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 8.0/IPHONEOS_DEPLOYMENT_TARGET = 12.0/g' Carthage/Checkouts/OHHTTPStubs/OHHTTPStubs.xcodeproj/project.pbxproj
carthage build --platform $PLATFORM --cache-builds --configuration $CONFIGURATION --use-xcframeworks