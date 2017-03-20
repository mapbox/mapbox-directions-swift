//
//  MBAnnotationType.swift
//  MapboxDirections
//
//  Created by Bobby Sudekum on 3/20/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

import Foundation

@objc(AnnotationType)
public enum AnnotationType: Int, CustomStringConvertible {

    case congestion
    
    case distance
    
    case duration
    
    case nodes
    
    case speed
    
    
    public init?(description: String) {
        let type: AnnotationType
        switch description {
        case "congestion":
            type = .congestion
        case "distance":
            type = .distance
        case "duration":
            type = .duration
        case "nodes":
            type = .nodes
        case "speed":
            type = .speed
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .congestion:
            return "congestion"
        case .distance:
            return "distance"
        case .duration:
            return "duration"
        case .nodes:
            return "nodes"
        case .speed:
            return "speed"
        }
    }

}

@objc(MBCongestionLevel)
public enum CongestionLevel: Int, CustomStringConvertible {
    
    case unknown
    
    case low
    
    case moderate
    
    case heavy
    
    case severe
    
    
    public init?(description: String) {
        let type: CongestionLevel
        switch description {
        case "unknown":
            type = .unknown
        case "low":
            type = .low
        case "moderate":
            type = .moderate
        case "heavy":
            type = .heavy
        case "severe":
            type = .severe
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .low:
            return "low"
        case .moderate:
            return "moderate"
        case .heavy:
            return "heavy"
        case .severe:
            return "severe"
        }
    }
    
}
