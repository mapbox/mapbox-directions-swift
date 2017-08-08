## Generating documentation locally

Run `scripts/document.sh`

## Update the documentation site:
1. Clone [mapbox-navigation-ios](https://github.com/mapbox/mapbox-navigation-ios) to a mapbox-navigation-ios-docs folder alongside your MapboxDirections.swift clone, and check out the `mb-pages` branch.
1. In your main MapboxDirections.swift clone, check out the release branch and run `OUTPUT=../mapbox-navigation-ios-docs/directions/X.X.X scripts/document.sh`, where _X.X.X_ is the new SDK version.
1. In mapbox-navigation-ios-docs, edit [directions/index.html](https://github.com/mapbox/mapbox-navigation-ios/blob/mb-pages/directions/index.html) and directions/docsets/Mapbox.xml to refer to the new SDK version.
1. Commit and push your changes to the mapbox-navigation-ios `mb-pages` branch.