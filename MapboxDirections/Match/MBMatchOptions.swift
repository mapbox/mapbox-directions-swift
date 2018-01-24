import Foundation

@objc(MBMatchOptions)
open class MatchOptions: RouteOptions {
    public init(tracePoints: [TracePoint], profileIdentifier: MBDirectionsProfileIdentifier?, resample: Bool?, timestamps: [Date]?) {
        super.init(waypoints: tracePoints, profileIdentifier: profileIdentifier)
    }
    
    @objc open var resample: Bool = false
    
    @objc open var timestamps: [Date]?
    
    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal var params: [URLQueryItem] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "geometries", value: String(describing: shapeFormat)),
            URLQueryItem(name: "overview", value: String(describing: routeShapeResolution)),
            URLQueryItem(name: "steps", value: String(includesSteps)),
            URLQueryItem(name: "language", value: locale.identifier),
            URLQueryItem(name: "tidy", value: String(describing: resample))
        ]
        
        if includesSpokenInstructions {
            params.append(URLQueryItem(name: "voice_instructions", value: String(includesSpokenInstructions)))
            params.append(URLQueryItem(name: "voice_units", value: String(describing: distanceMeasurementSystem)))
        }
        
        if includesVisualInstructions {
            params.append(URLQueryItem(name: "banner_instructions", value: String(includesVisualInstructions)))
        }
        
        if !attributeOptions.isEmpty {
            let attributesStrings = String(describing:attributeOptions)
            
            params.append(URLQueryItem(name: "annotations", value: attributesStrings))
        }
        
        if let timestamps = timestamps, !timestamps.isEmpty {
            let timeStrings = timestamps.map {
                String(describing: $0.timeIntervalSince1970)
            }.joined(separator: ",")
            
            params.append(URLQueryItem(name: "timestamps", value: timeStrings))
        }
        
        return params
    }
    
    override internal var path: String {
        assert(!queries.isEmpty, "No query")
        
        let queryComponent = queries.joined(separator: ";")
        return "matching/v5/\(profileIdentifier.rawValue)/\(queryComponent).json"
    }
    
    internal func responseMatchOptions(from json: JSONDictionary) -> ([TracePoint]?, [Match]?) {
        var namedWaypoints: [TracePoint]?
        if let jsonWaypoints = (json["tracePoints"] as? [JSONDictionary]) {
            namedWaypoints = zip(jsonWaypoints, self.waypoints).map { (api, local) -> TracePoint in
                let location = api["location"] as! [Double]
                let coordinate = CLLocationCoordinate2D(geoJSON: location)
                let alternateCount = api["alternatives_count"] as! Int
                let waypointIndex = api["waypoint_index"] as! Int
                let matchingIndex = api["matchings_index"] as! Int
                let name = api["name"] as? String
                // TODO: add name
                // let possibleAPIName = api["name"] as? String
                return TracePoint(coordinate: coordinate, alternateCount: alternateCount, waypointIndex: waypointIndex, matchingIndex: matchingIndex, name: name)
            }
        }
        
        let tracePoints = namedWaypoints!
        
        let matchings = (json["matchings"] as? [JSONDictionary])?.map {_ in 
            Match(json: json, tracePoints: tracePoints, matchOptions: self)
        }
        return (tracePoints, matchings)
    }
}
