#  Mapbox Directions CLI

## Getting Started
`MapboxDirectionsCLI` is a command line tool, designed to round-trip a Directions or Map Matching API response through model objects and back to JSON, plain text, or GPX. This is useful for various scenarios including testing purposes and designing more sophisticated API response processing pipelines. It is also supplied as a Swift package.

To build `MapboxDirectionsCLI` using Carthage pipeline:

1. `carthage bootstrap --platform macos --use-xcframeworks`
2. `open MapboxDirections.xcodeproj`
3. Select `MapboxDirectionsCLI` target.

After selecting the `MapboxDirectionsCLI` target, edit the scheme to include the desired argument and add your `access_token` as an environment variable.

To build `MapboxDirectionsCLI` using SPM:

1. `swift build`
2. `swift run MapboxDirectionsCLI -h` to see usage.

## Usage and Recipes

`MapboxDirectionsCLI` is a useful tool for mobile quality assurance. There are several

### 

