## Generating documentation locally

Make sure you’ve got the latest version of jazzy installed, then run `scripts/document.sh`.

## Update the documentation site:
1. Clone [mapbox-navigation-ios](https://github.com/mapbox/mapbox-navigation-ios) to a mapbox-navigation-ios-docs folder alongside your MapboxDirections.swift clone, and check out the `mb-pages` branch.
1. In your main MapboxDirections.swift clone, check out the release branch and run `OUTPUT=../mapbox-navigation-ios-docs/directions VERSION=X.X.X scripts/document.sh`, where _X.X.X_ is the new SDK version.
1. Commit and push your changes to the mapbox-navigation-ios `mb-pages` branch.
