
import Foundation
import MapboxDirections
import SwiftCLI


// input Directions or Map Mathcing JSON
// input RouteOptions or MatchOptions as arguments (or filepath?)
// decode/encode it into objects
// output JSON

private let BogusCredentials = DirectionsCredentials(accessToken: "pk.feedCafeDadeDeadBeef-BadeBede.FadeCafeDadeDeed-BadeBede")

class ProcessCommand<ResponceType : Codable, OptionsType : DirectionsOptions > : Command {
    var name = "process"
    
    @Key("-i", "--input", description: "Filepath to the input JSON.")
    var inputPath: String?
    
    @Key("-c", "--config", description: "Filepath to the JSON, containing serialized Options data.")
    var configPath: String?
    
    @Key("-o", "--output", description: "[Optional] Output filepath to save the conversion result. If no filepath provided - will output to the shell.")
    var outputPath: String?
    
    var customShortDescription: String = ""
    var shortDescription: String {
        return customShortDescription
    }
    
    
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
    
    init(name: String, shortDescription: String = "") {
        self.name = name
        self.customShortDescription = shortDescription
    }
    
    func execute() throws {
        guard let inputPath = inputPath else { exit(1) }
        guard let configPath = configPath else { exit(1) }
        
        let input = FileManager.default.contents(atPath: absURL(inputPath).path)!
        let config = FileManager.default.contents(atPath: absURL(configPath).path)!
        
        let decoder = JSONDecoder()
        
        var directionsOptions: OptionsType!
        do {
            directionsOptions = try decoder.decode(OptionsType.self, from: config)
        } catch {
            print("Failed to decode input Options file.")
            print(error)
            exit(1)
        }
        
        decoder.userInfo = [.options: directionsOptions!,
                            .credentials: BogusCredentials]
        var data: Data!
        do {
            data = try processResponse(decoder, type: ResponceType.self, from: input)
        } catch {
            print("Failed to decode input JSON file.")
            print(error)
            exit(1)
        }
        
        if let outputPath = outputPath {
            do {
                try data.write(to: absURL(outputPath))
            } catch {
                print("Failed to save results to output file.")
                print(error)
                exit(1)
            }
        } else {
            print(String(data: data, encoding: .utf8)!)
        }
    }
}


