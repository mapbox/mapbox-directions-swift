
import Foundation
import MapboxDirections

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
    
    private func processOutput(_ data: Data, routeResponse: RouteResponse?) throws {
        var outputText: String = ""
        
        switch options.outputFormat {
        case .text:
            outputText = String(data: data, encoding: .utf8)!
        case .json:
            if let object = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
                outputText = String(data: jsonData, encoding: .utf8)!
            }
        case .gpx:
            var gpxText: String = String("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
            gpxText.append("\n<gpx")
            // do we need to include additional tags like metadata or the schema version?
            
            guard let routeResponse = routeResponse else { return }
            guard let routes = routeResponse.routes else { return }
            routes.forEach { route in
                let shape = route.shape
                for coord in shape!.coordinates {
                    gpxText.append("\n<wpt lat=\"\(coord.latitude)\" lon=\"\(coord.longitude)\">")
                    gpxText.append("</wpt>")
                }
            }
            gpxText.append("\n</gpx>")
            outputText = gpxText
        }
        
        if let outputPath = options.outputPath {
            try outputText.write(toFile: NSString(string: outputPath).expandingTildeInPath,
                                 atomically: true,
                                 encoding: .utf8)
        } else {
            print(outputText)
        }
    }
    
    init(options: ProcessingOptions) {
        self.options = options
    }
    
    // MARK: - Command implementation
    
    func execute() throws {
        
        let input = FileManager.default.contents(atPath: NSString(string: options.inputPath).expandingTildeInPath)!
        let config = FileManager.default.contents(atPath: NSString(string: options.configPath).expandingTildeInPath)!
        
        let decoder = JSONDecoder()
        
        let directionsOptions = try decoder.decode(OptionsType.self, from: config)
        
        decoder.userInfo = [.options: directionsOptions,
                            .credentials: BogusCredentials]
        
        var routeResponse: RouteResponse!
        if options.outputFormat == .gpx {
            guard let gpxData = try String(contentsOfFile: options.inputPath).data(using: .utf8) else { exit(1)}
            routeResponse = try! decoder.decode(RouteResponse.self, from: gpxData)
        }
        let data = try processResponse(decoder, type: ResponceType.self, from: input)
        
        try processOutput(data, routeResponse: routeResponse)
    }
}
