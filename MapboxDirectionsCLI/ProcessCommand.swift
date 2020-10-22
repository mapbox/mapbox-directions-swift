
import Foundation
import MapboxDirections
import SwiftCLI


// input Directions or Map Mathcing JSON
// input RouteOptions or MatchOptions as arguments (or filepath?)
// decode/encode it into objects
// output JSON

let BogusToken = "pk.feedCafeDadeDeadBeef-BadeBede.FadeCafeDadeDeed-BadeBede"
let BogusCredentials = DirectionsCredentials(accessToken: BogusToken)

class ProcessCommand: Command {
    let name = "process"
    
    @Key("-i", "--input", description: "Filepath to the input JSON. Could be Directions or Map Matching.")
    var inputPath: String?
    
    @Key("-c", "--config", description: "Filepath to the options JSON. Could be `RouteOptions` or `MatchOptions`, depending on the `--input` type. Mismatching types will produce an error.")
    var configPath: String?
    
    @Key("-o", "--output", description: "[Optional] Output filepath to save the conversion result. If no filepath provided - will output to the shell.")
    var outputPath: String?
    
    private var isMatch = false
    
    private func processResponse<T>(_ decoder: JSONDecoder, type: T.Type, from data: Data) throws -> Data where T : Codable {
        let result = try decoder.decode(type, from: data)
        let encoder = JSONEncoder()
        return try encoder.encode(result)
    }
    
    private func absURL ( _ path: String ) -> URL {
        // some methods cannot correctly expand '~' in a path, so we'll do it manually
        let homeDirectory = URL(fileURLWithPath: NSHomeDirectory())
        guard path != "~" else {
            return homeDirectory
        }
        guard path.hasPrefix("~/") else { return URL(fileURLWithPath: path)  }

        var relativePath = path
        relativePath.removeFirst(2)
        return URL(string: relativePath,
                   relativeTo: homeDirectory) ?? homeDirectory
    }
    
    func execute() throws {
        guard let inputPath = inputPath else { exit(1) }
        guard let configPath = configPath else { exit(1) }
        
        let unwrappedInput = absURL(inputPath).path
        let unwrappedConfig = absURL(configPath).path
        // /Users/viktorkononov/CaS
        let input = FileManager.default.contents(atPath: unwrappedInput)!//unwrappedInput)!
        let config = FileManager.default.contents(atPath: unwrappedConfig)!
        
        let decoder = JSONDecoder()
        
        var options: DirectionsOptions? = try? decoder.decode(RouteOptions.self, from: config)
        if options == nil {
            isMatch = true
            options = try? decoder.decode(MatchOptions.self, from: config)
        }
        
        guard let directionsOptions = options else {
            exit(1)
        }
        
        decoder.userInfo = [.options: directionsOptions,
                            .credentials: BogusCredentials]
        var data: Data?
        do {
            if isMatch {
                data = try processResponse(decoder, type: MapMatchingResponse.self, from: input)
            } else {
                data = try processResponse(decoder, type: RouteResponse.self, from: input)
            }
        } catch {
            print(error)
        }
        
        if let outputPath = outputPath {
            try data?.write(to: URL(fileURLWithPath: outputPath))
        } else {
            if let data = data {
                print(String(data: data, encoding: .utf8)!)
            } else {
                exit(1)
            }
        }
    }
}


