# Contributing to Maplibre Directions for Swift

## Reporting an issue

Bug reports and feature requests are more than welcome, but please consider the following tips so we can respond to your feedback more effectively.

Before reporting a bug here, please determine whether the issue lies with the MaplibreDirections package or with another Maplibre/Mapbox  product:

When reporting a bug in the client-side MaplibreDirections package, please indicate:

* The version of MaplibreDirections you installed
* The version of Carthage that you used to install the package
* The version of Xcode you used to build the package
* The operating system version and device model on which you experienced the issue

## Adding tests

### Adding a test case

1. Add a `test*` method to one of the classes in one of the files in [Tests/MapboxDirectionsTests/](./Tests/MapboxDirectionsTests/).

## Opening a pull request

Pull requests are appreciated. If your PR includes any changes that would impact developers or end users, please mention those changes in the “main” section of [CHANGELOG.md](CHANGELOG.md), noting the PR number. Examples of noteworthy changes include new features, fixes for user-visible bugs, and renamed or deleted public symbols.

Before we can merge your PR, it must pass automated continuous integration checks on each of the supported platforms, as well as a check to ensure that code coverage has not decreased significantly.

## Setup for creating pull requests

* Fork this project
* In your fork, create a branch, for example: fix/camera-update
* Add your changes
* Push and open a PR with your branch
