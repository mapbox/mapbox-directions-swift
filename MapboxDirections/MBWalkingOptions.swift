import Foundation


/**
 A `WalkingOptions` object is a structure that specifies the criteria for results returned by the Mapbox Directions API.
 
 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
@objc(MBWalkingOptions)
open class WalkingOptions: DirectionsOptions {
    
    /**
     A bias which determines whether the route should prefer or avoid the use of alleys. The
     allowed range of values is from -1.0 to 1.0, where -1 indicates preference to avoid
     alleys, 1 indicates preference to favor alleys, and 0 indicates no preference.
     
     Defaults to 0
     */
    open var alleyBias: Double? = 0
    
    /**
     A bias which determines whether the route should prefer or avoid the use of roads or paths
     that are set aside for pedestrian-only use (walkways). The allowed range of values is from
     -1.0 to 1.0, where -1 indicates indicates preference to avoid walkways, 1 indicates preference
     to favor walkways, and 0 indicates no preference.
     
     Defeaults to 0
     */
    open var walkwayBias: Double? = 0
    
    /**
     Walking speed in meters per second. Must be between 0.14 and 6.94 meters per second.
     
     Defaults to 1.42
     */
    open var walkingSpeed: CLLocationSpeed? = 1.42
    
    override var abridgedPath: String {
        return "directions/v5/\(profileIdentifier.rawValue)"
    }
    
    public required init(waypoints: [Waypoint]) {
        super.init(waypoints: waypoints, profileIdentifier: .walking)
    }
    
    public required init?(coder decoder: NSCoder) {
        if let alleyBias = decoder.decodeObject(of: NSNumber.self, forKey: "alleyBias") {
            self.alleyBias = alleyBias.doubleValue
        }
        
        if let walkwayBias = decoder.decodeObject(of: NSNumber.self, forKey: "walkwayBias") {
            self.walkwayBias = walkwayBias.doubleValue
        }
        
        if let walkingSpeed = decoder.decodeObject(of: NSNumber.self, forKey: "walkingSpeed") {
            self.walkingSpeed = walkingSpeed.doubleValue
        }
        
        super.init(coder: decoder)
    }
    
    public override func encode(with coder: NSCoder) {
        coder.encode(alleyBias, forKey: "alleyBias")
        coder.encode(walkwayBias, forKey: "walkwayBias")
        coder.encode(walkingSpeed, forKey: "walkingSpeed")
        super.encode(with: coder)
    }
    
    @objc required public init(waypoints: [Waypoint], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        fatalError("init(waypoints:profileIdentifier:) has not been implemented")
    }
    
    open override var urlQueryItems: [URLQueryItem] {
        var queryItems = super.urlQueryItems
        
        if let alleyBias = self.alleyBias {
            queryItems.append(URLQueryItem(name: "alley_bias", value: String(alleyBias)))
        }
        
        if let walkwayBias = self.walkwayBias {
            queryItems.append(URLQueryItem(name: "walkway_bias", value: String(walkwayBias)))
        }
        
        if let walkingSpeed = self.walkingSpeed {
            queryItems.append(URLQueryItem(name: "walking_speed", value: String(walkingSpeed)))
        }
        
        return queryItems
    }
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! WalkingOptions
        copy.alleyBias = alleyBias
        copy.walkwayBias = walkwayBias
        copy.walkingSpeed = walkingSpeed
        return copy
    }
    
    //MARK: - OBJ-C Equality
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let opts = object as? WalkingOptions else { return false }
        return isEqual(to: opts)
    }
    
    @objc(isEqualToWalkingOptions:)
    open func isEqual(to walkingOptions: WalkingOptions?) -> Bool {
        guard let other = walkingOptions else { return false }
        guard super.isEqual(to: walkingOptions) else { return false}
        guard alleyBias == other.alleyBias,
            walkwayBias == other.walkwayBias,
            walkingSpeed == other.walkingSpeed else { return false }
        
        return true
    }
}
