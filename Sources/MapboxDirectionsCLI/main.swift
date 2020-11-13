#!/usr/bin/swift

import Foundation
import MapboxDirections
import SwiftCLI


let match = ProcessCommand< MapMatchingResponse, MatchOptions > (name: "match",
                                                                 shortDescription: "Command to process Map Matching Data")
let route = ProcessCommand< MapboxDirections.RouteResponse, RouteOptions>(name: "route",
                                                                          shortDescription: "Command to process Routing Data")

CLI(name: "mapbox-directions-swift",
    description: "'mapbox-directions-swift' is a command line tool, designed to round-trip an arbitrary, JSON-formatted Directions or Map Matching API response through model objects and back to JSON.",
    commands: [route, match]).goAndExit()
