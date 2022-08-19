#!/usr/bin/swift

import Foundation
import MapboxDirections
import ArgumentParser


struct ProcessingOptions: ParsableArguments {
    
    @Option(name: [.short, .customLong("input")], help: "[Optional] Filepath to the input JSON. If no filepath provided - will fall back to Directions API request using locations in config file.")
    var inputPath: String?
    
    @Option(name: [.short, .customLong("config")], help: "Filepath to the JSON, containing serialized Options data.")
    var configPath: String
    
    @Option(name: [.short, .customLong("output")], help: "[Optional] Output filepath to save the conversion result. If no filepath provided - will output to the shell.")
    var outputPath: String?
    
    @Option(name: [.customShort("f"), .customLong("format")], help: "Output format. Supports `text`, `json`, and `gpx` formats.")
    var outputFormat: OutputFormat = .text
    
    enum OutputFormat: String, ExpressibleByArgument, CaseIterable {
        case text
        case json
        case gpx
    }
}

struct Command: ParsableCommand {
    static var accessToken: String {
        get throws {
            guard let accessToken = ProcessInfo.processInfo.environment["MAPBOX_ACCESS_TOKEN"] ??
                    UserDefaults.standard.string(forKey: "MBXAccessToken") else {
                throw ValidationError("A Mapbox access token is required. Go to <https://account.mapbox.com/access-tokens/>, then set the MAPBOX_ACCESS_TOKEN environment variable to your access token.")
            }
            return accessToken
        }
    }
    
    static var configuration = CommandConfiguration(
        commandName: "mapbox-directions-swift",
        abstract: "'mapbox-directions-swift' is a command line tool, designed to round-trip an arbitrary, JSON-formatted Directions or Map Matching API response through model objects and back to JSON.",
        subcommands: [Match.self, Route.self]
    )
    
    fileprivate static func validateInput(_ options: ProcessingOptions) throws {
        
        guard FileManager.default.fileExists(atPath: options.configPath) else {
            throw ValidationError("Options JSON file `\(options.configPath)` does not exist.")
        }
    }
}

extension Command {
    struct Match: ParsableCommand {
        static var configuration =
            CommandConfiguration(commandName: "match",
                                    abstract: "Command to process Map Matching Data.")
        
        @ArgumentParser.OptionGroup var options: ProcessingOptions
        
        mutating func validate() throws {
            try Command.validateInput(options)
        }
        
        mutating func run() throws {
            let credentials = Credentials(accessToken: try accessToken)
            try CodingOperation<MapMatchingResponse, MatchOptions>(options: options, credentials: credentials).execute()
        }
    }
}

extension Command {
    struct Route: ParsableCommand {
        static var configuration =
                    CommandConfiguration(commandName: "route",
                                         abstract: "Command to process Routing Data.")
        
        @ArgumentParser.OptionGroup var options: ProcessingOptions
        
        mutating func validate() throws {
            try Command.validateInput(options)
        }
        
        mutating func run() throws {
            let credentials = Credentials(accessToken: try accessToken)
            try CodingOperation<RouteResponse, RouteOptions>(options: options, credentials: credentials).execute()
        }
    }
}


Command.main()
