#!/usr/bin/swift

import Foundation
import MapboxDirections
import ArgumentParser


struct ProcessingOptions: ParsableArguments {
    
    @ArgumentParser.Option(name: [.short, .customLong("input")], help: "Filepath to the input JSON.")
    var inputPath: String?
    
    @ArgumentParser.Option(name: [.short, .customLong("config")], help: "Filepath to the JSON, containing serialized Options data.")
    var configPath: String?
    
    @ArgumentParser.Option(name: [.short, .customLong("output")], help: "[Optional] Output filepath to save the conversion result. If no filepath provided - will output to the shell.")
    var outputPath: String?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")], help: "Output format. Supports `text` and `json` formats.")
    var outputFormat: OutputFormat = .text
    
    enum OutputFormat: String, ExpressibleByArgument {
        case text
        case json
    }
}

struct Process: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "mapbox-directions-swift",
        abstract: "'mapbox-directions-swift' is a command line tool, designed to round-trip an arbitrary, JSON-formatted Directions or Map Matching API response through model objects and back to JSON.",
        
        subcommands: [Match.self, Route.self]
    )
}

extension Process {
    struct Match: ParsableCommand {
        static var configuration =
            CommandConfiguration(commandName: "match",
                                    abstract: "Command to process Map Matching Data.")
        
        @ArgumentParser.OptionGroup var options: ProcessingOptions
        
        mutating func run() {
            try? ProcessCommand<MapMatchingResponse, MatchOptions>(options: options).execute()
        }
    }
}

extension Process {
    struct Route: ParsableCommand {
        static var configuration =
                    CommandConfiguration(commandName: "route",
                                         abstract: "Command to process Routing Data.")
        
        @ArgumentParser.OptionGroup var options: ProcessingOptions
        
        mutating func run() {
            try? ProcessCommand<MapboxDirections.RouteResponse, RouteOptions>(options: options).execute()
        }
    }
}


Process.main()
