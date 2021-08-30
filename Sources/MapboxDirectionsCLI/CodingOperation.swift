
import Foundation
import MapboxDirections
import CoreLocation

private let BogusCredentials = Credentials(accessToken: "pk.feedCafeDadeDeadBeef-BadeBede.FadeCafeDadeDeed-BadeBede")

class CodingOperation<ResponceType : Codable, OptionsType : DirectionsOptions > {
    
    // MARK: - Parameters
    
    let options: ProcessingOptions
    
    // MARK: - Helper methods
    
    private func processResponse<T>(_ decoder: JSONDecoder, type: T.Type, from data: Data) throws -> Data where T : Codable {
        let result = try decoder.decode(type, from: data)
        let encoder = JSONEncoder()
        return try encoder.encode(result)
    }
    
    private func processOutput(_ data: Data) throws {
        var outputText: String = ""
        
        switch options.outputFormat {
        case .text:
            outputText = String(data: data, encoding: .utf8)!
        case .json:
            if let object = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
                outputText = String(data: jsonData, encoding: .utf8)!
            }
        }
        
        if let outputPath = options.outputPath {
            try outputText.write(toFile: NSString(string: outputPath).expandingTildeInPath,
                                 atomically: true,
                                 encoding: .utf8)
        } else {
            print(outputText)
        }
    }
    
    private func convertURLToOptions(from url: URL?) -> OptionsType? {
        
        guard let url = url else { return nil }
        let pathComponents = url.pathComponents
        guard pathComponents[1] == "directions",
              pathComponents[2] == "v5",
              pathComponents.count == 6 else { return nil }
        
        let waypoints = url.deletingPathExtension().lastPathComponent
            .split(separator: ";")
            .map { $0.split(separator: ",", maxSplits: 1) }
            .map { CLLocationCoordinate2D(latitude: Double($0[1])!, longitude: Double($0[0])!) }
            .map { Waypoint(coordinate: $0) }
        let profileIdentifier = DirectionsProfileIdentifier(rawValue: pathComponents[3..<5].joined(separator: "/"))

        return OptionsType(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    init(options: ProcessingOptions) {
        self.options = options
    }
    
    // MARK: - Command implementation
    
    func execute() throws {
        
        let input = FileManager.default.contents(atPath: NSString(string: options.inputPath).expandingTildeInPath)!
        let config = FileManager.default.contents(atPath: NSString(string: options.configPath).expandingTildeInPath)!
        
        let decoder = JSONDecoder()
        
        if let url = options.url {
            let options = convertURLToOptions(from: URL(string: url))
            print("!!! options: \(String(describing: options?.waypoints))")
        }
        
        let directionsOptions = try decoder.decode(OptionsType.self, from: config)
        
        decoder.userInfo = [.options: directionsOptions,
                            .credentials: BogusCredentials]
        let data = try processResponse(decoder, type: ResponceType.self, from: input)
        
        try processOutput(data)
    }
}
