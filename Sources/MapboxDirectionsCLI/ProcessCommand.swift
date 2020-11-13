
import Foundation
import MapboxDirections
import SwiftCLI


private let BogusCredentials = DirectionsCredentials(accessToken: "pk.feedCafeDadeDeadBeef-BadeBede.FadeCafeDadeDeed-BadeBede")

class ProcessCommand<ResponceType : Codable, OptionsType : DirectionsOptions > : Command {
    
    // MARK: - Parameters
    
    var name = "process"
    
    @Key("-i", "--input", description: "Filepath to the input JSON.")
    var inputPath: String?
    
    @Key("-c", "--config", description: "Filepath to the JSON, containing serialized Options data.")
    var configPath: String?
    
    @Key("-o", "--output", description: "[Optional] Output filepath to save the conversion result. If no filepath provided - will output to the shell.")
    var outputPath: String?
    
    @Key("-f", "--format", description: "Output format. Supports `text` and `json` formats. Defaults to `text`")
    var outputFormat: OutputFormat?
    
    enum OutputFormat: String, ConvertibleFromString {
        case text
        case json
    }
    
    var customShortDescription: String = ""
    var shortDescription: String {
        return customShortDescription
    }
    
    // MARK: - Helper methods
    
    private func processResponse<T>(_ decoder: JSONDecoder, type: T.Type, from data: Data) throws -> Data where T : Codable {
        let result = try decoder.decode(type, from: data)
        let encoder = JSONEncoder()
        return try encoder.encode(result)
    }
    
    private func processOutput(_ data: Data) {
        var outputText: String = ""
        
        switch outputFormat {
        case .text, .none:
            outputText = String(data: data, encoding: .utf8)!
        case .json:
            if let object = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
                outputText = String(data: jsonData, encoding: .utf8)!
            }
        }
        
        if let outputPath = outputPath {
            do {
                try outputText.write(toFile: NSString(string: outputPath).expandingTildeInPath,
                                     atomically: true,
                                     encoding: .utf8)
            } catch {
                print("Failed to save results to output file.")
                print(error)
                exit(1)
            }
        } else {
            print(outputText)
        }
    }
    
    init(name: String, shortDescription: String = "") {
        self.name = name
        self.customShortDescription = shortDescription
    }
    
    // MARK: - Command implementation
    
    func execute() throws {
        guard let inputPath = inputPath else { exit(1) }
        guard let configPath = configPath else { exit(1) }
        
        let input = FileManager.default.contents(atPath: NSString(string: inputPath).expandingTildeInPath)!
        let config = FileManager.default.contents(atPath: NSString(string: configPath).expandingTildeInPath)!
        
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
        
        processOutput(data)
    }
}


