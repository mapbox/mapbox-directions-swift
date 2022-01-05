import Foundation
import MapboxDirections
import Turf

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
    
    private func processOutput(_ data: Data,
                               routeResponse: RouteResponse? = nil,
                               matchResponse: MapMatchingResponse? = nil) throws {
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
            gpxText.append("\n<gpx xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.topografix.com/GPX/1/1\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\" version=\"1.1\">")
            
            if let routeResponse = routeResponse,
               let routes = routeResponse.routes {
                routes.forEach { route in
                    let text = populateGPX(route)
                    gpxText.append(text)
                    if routes.count > 1 {
                        gpxText.append("<!--Moving to next route-->")
                    }
                }
            } else if let matchResponse = matchResponse,
                      let matches = matchResponse.matches {
                matches.forEach { match in
                    let text = populateGPX(nil, match)
                    gpxText.append(text)
                    if matches.count > 1 {
                        gpxText.append("<!--Moving to next match-->")
                    }
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
    
    private func populateGPX(_ route: Route? = nil, _ match: Match? = nil) -> String {
        let timeInterval: TimeInterval = 1
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withInternetDateTime
        var time = Date()
        var text: String = ""
        var coordinates: [LocationCoordinate2D?] = []
        
        if route != nil {
            guard let route = route else { return "" }
            coordinates = interpolate(shape: route.shape,
                                      expectedTravelTime: route.expectedTravelTime,
                                      distance: route.distance,
                                      timeInterval: timeInterval)
        } else if match != nil {
            guard let match = match else { return "" }
            coordinates = interpolate(shape: match.shape,
                                      expectedTravelTime: match.expectedTravelTime,
                                      distance: match.distance,
                                     timeInterval: timeInterval)
        }
        
        for coord in coordinates {
            guard let lat = coord?.latitude, let lon = coord?.longitude else { continue }
            text.append("\n<wpt lat=\"\(lat)\" lon=\"\(lon)\">")
            text.append("\n\t<time> \(dateFormatter.string(from: time)) </time>")
            text.append("\n</wpt>")
            time.addTimeInterval(timeInterval)
        }
        return text
    }
    
    private func interpolate(shape: LineString?, expectedTravelTime: TimeInterval, distance: LocationDistance, timeInterval: TimeInterval) -> [LocationCoordinate2D?] {
        guard expectedTravelTime > 0, let polyline = shape,
              let firstCoordinate = polyline.coordinates.first,
              let lastCoordinate = polyline.coordinates.last else { return [] }
        
        var distanceAway: LocationDistance = 0
        let distancePerTick = distance/expectedTravelTime
        var interpolatedCoordinates = [firstCoordinate]
        while distanceAway <= distance {
            if let nextCoordinate = polyline.coordinateFromStart(distance: distanceAway) {
                interpolatedCoordinates.append(nextCoordinate)
            }
            distanceAway += distancePerTick * timeInterval
        }
        interpolatedCoordinates.append(lastCoordinate)
        return interpolatedCoordinates
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
        
        var routeResponse: RouteResponse?
        var matchResponse: MapMatchingResponse?
        if options.outputFormat == .gpx {
            let gpxData = try String(contentsOfFile: options.inputPath).data(using: .utf8)!
            do {
                routeResponse = try decoder.decode(RouteResponse.self, from: gpxData)
            } catch {
                matchResponse = try decoder.decode(MapMatchingResponse.self, from: gpxData)
            }
        }
        let data = try processResponse(decoder, type: ResponceType.self, from: input)
        
        try processOutput(data, routeResponse: routeResponse, matchResponse: matchResponse)
    }
}
