//
//  MBTracepoint.swift
//  MapboxDirections
//
//  Created by Bobby Sudekum on 1/10/18.
//  Copyright © 2018 Mapbox. All rights reserved.
//

import Foundation

@objc(MBTracePoint)
class TracePoint: Waypoint {
    
    @objc open var location: CLLocationCoordinate2D
    
    @objc open var alternateCount: Int
    
    @objc open var waypointIndex: Int
    
    @objc open var matchingIndex: Int
    
    @objc open var name: String
    
}
