import Foundation
import MapboxDirections
import Turf
import CoreLocation

let accessToken: String? =
    ProcessInfo.processInfo.environment["access_token"] ??
    UserDefaults.standard.string(forKey: "MBXAccessToken")
let credentials = DirectionsCredentials(accessToken: accessToken!)
private let directions = Directions(credentials: credentials)

protocol DirectionsResultsProvider {
    var directionsResults: [DirectionsResult]? { get }
}

extension RouteResponse: DirectionsResultsProvider {
    var directionsResults: [DirectionsResult]? { routes }
}

extension MapMatchingResponse: DirectionsResultsProvider {
    var directionsResults: [DirectionsResult]? { matches }
}

class CodingOperation<ResponseType : Codable & DirectionsResultsProvider, OptionsType : DirectionsOptions > {
    
    // MARK: - Parameters
    
    let options: ProcessingOptions
    
    // MARK: - Helper methods
    
    private func processResponse(_ decoder: JSONDecoder, from data: Data) throws -> (Data, ResponseType) {
        let result = try decoder.decode(ResponseType.self, from: data)
        let encoder = JSONEncoder()
        let data = try encoder.encode(result)
        return (data, result)
    }
    
    private func processOutput(_ data: Data,
                               directionsResultsProvider: DirectionsResultsProvider? = nil) throws {
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
            
            if let directionsResultsProvider = directionsResultsProvider,
               let directionsResults = directionsResultsProvider.directionsResults {
                directionsResults.forEach { result in
                    let text = populateGPX(result)
                    gpxText.append(text)
                    if directionsResults.count > 1 {
                        gpxText.append("<!--Moving to next route-->")
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
    
    private func populateGPX(_ result: DirectionsResult?) -> String {
        let timeInterval: TimeInterval = 1
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withInternetDateTime
        var time = Date()
        var text: String = ""
        var coordinates: [LocationCoordinate2D?] = []
        
        guard let result = result else { return "" }
        coordinates = interpolate(shape: result.shape,
                                  expectedTravelTime: result.expectedTravelTime,
                                  distance: result.distance,
                                  timeInterval: timeInterval)
        
        for coord in coordinates {
            guard let lat = coord?.latitude, let lon = coord?.longitude else { continue }
            text.append("\n<wpt lat=\"\(lat)\" lon=\"\(lon)\">")
            text.append("\n\t<time> \(dateFormatter.string(from: time)) </time>")
            text.append("\n</wpt>")
            time.addTimeInterval(timeInterval)
        }
        return text
    }
    
    private func interpolate(shape: LineString?,
                             expectedTravelTime: TimeInterval,
                             distance: LocationDistance,
                             timeInterval: TimeInterval) -> [LocationCoordinate2D?] {
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
    
    private func requestResponse(_ coordinates: [Waypoint]?, includesSteps: Bool?) -> (Data?, Data) {
        let semaphore = DispatchSemaphore(value: 0)
        
        guard let waypoints = coordinates, let includesSteps = includesSteps else {
            print("Failed to request response without coordinates.")
            exit(1) }
        
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: .automobileAvoidingTraffic)
        options.includesSteps = includesSteps
        var responseData: Data?
        
        let url = directions.url(forCalculating: options)
        let urlSession = URLSession(configuration: .ephemeral)

        let task = urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            responseData = data
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
        let encoder = JSONEncoder()
        let encodedOptions = try! encoder.encode(options)
        
        return (responseData, encodedOptions)
    }
    
    init(options: ProcessingOptions) {
        self.options = options
    }
    
    // MARK: - Command implementation
    
    func execute() throws {
        
//        let input = FileManager.default.contents(atPath: NSString(string: options.inputPath).expandingTildeInPath)!
        let config = FileManager.default.contents(atPath: NSString(string: options.configPath).expandingTildeInPath)!
        let input: Data!
        
        let decoder = JSONDecoder()
        
        let directionsOptions = try decoder.decode(OptionsType.self, from: config)
        
        if let inputPath = options.inputPath {
            input = FileManager.default.contents(atPath: NSString(string: inputPath).expandingTildeInPath)!
        } else {
            let response = requestResponse(directionsOptions.waypoints, includesSteps: directionsOptions.includesSteps)
            input = response.0
        }
        
        decoder.userInfo = [.options: directionsOptions,
                            .credentials: credentials]
        
        let (data, directionsResultsProvider) = try processResponse(decoder, from: input)
        
        try processOutput(data, directionsResultsProvider: directionsResultsProvider)
    }
}
