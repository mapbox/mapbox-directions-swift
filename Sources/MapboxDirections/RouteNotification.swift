import Foundation
import Turf

extension RouteLeg {
    public class Notification: Codable, ForeignMemberContainerClass {
        public var foreignMembers: JSONObject = [:]
        
        enum CodingKeys: String, CodingKey, CaseIterable {
            case type
            case subtype
            case geometryIndexStart = "geometry_index_start"
            case geometryIndexEnd = "geometry_index_end"
            case details
        }
        
        enum NotificationType: String, Codable {
            case violation
//            case alert // API under construction atm.
        }
        
        enum ViolationType: String, Codable {
            case maxHeight
            case maxWidth
            case maxWeight
            case unpaved
            case pointExclusion
            case countryBorderCrossing
        }
        
        public enum Kind {
            case violation(Violation)
//            case alert(Alert) // API under construction atm.
        }
        
        /// The type of notification
        public let kind: Kind
        /// The range of segments within the overall leg, where the notification spans.
        ///
        /// `nil` value indicates this event is related to the entire leg.
        public let shapeIndexRange: Range<Int>?
        
        required public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let geometryIndexStart = try container.decodeIfPresent(Int.self, forKey: .geometryIndexStart)
            let geometryIndexEnd = try container.decodeIfPresent(Int.self, forKey: .geometryIndexEnd)
            if let geometryIndexStart = geometryIndexStart,
               let geometryIndexEnd = geometryIndexEnd {
                self.shapeIndexRange = geometryIndexStart..<geometryIndexEnd
            } else {
                self.shapeIndexRange = nil
            }
            
            let type = try container.decode(NotificationType.self, forKey: .type)
            
            switch type {
            case .violation:
                let subtype = try container.decode(ViolationType.self, forKey: .subtype)
                
                switch subtype {
                case .maxHeight:
                    self.kind = .violation(try container.decode(MaxHeightViolation.self, forKey: .details))
                case .maxWidth:
                    self.kind = .violation(try container.decode(MaxWidthViolation.self, forKey: .details))
                case .maxWeight:
                    self.kind = .violation(try container.decode(MaxWeightViolation.self, forKey: .details))
                case .unpaved:
                    self.kind = .violation(try container.decode(UnpavedRoadViolation.self, forKey: .details))
                case .pointExclusion:
                    self.kind = .violation(try container.decode(PointExclusionViolation.self, forKey: .details))
                case .countryBorderCrossing:
                    self.kind = .violation(try container.decode(CountryBorderCrossingViolation.self, forKey: .details))
                }
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            if let shapeIndexRange = shapeIndexRange {
                try container.encode(shapeIndexRange.lowerBound, forKey: .geometryIndexStart)
                try container.encode(shapeIndexRange.upperBound, forKey: .geometryIndexEnd)
            }
            
            switch kind {
            case let .violation(violation):
                try container.encode(NotificationType.violation, forKey: .type)
                try container.encode(violation, forKey: .details)
                
                var subtype: ViolationType
                switch violation {
                case is MaxHeightViolation:
                    subtype = .maxHeight
                case is MaxWidthViolation:
                    subtype = .maxWidth
                case is MaxWeightViolation:
                    subtype = .maxWeight
                case is UnpavedRoadViolation:
                    subtype = .unpaved
                case is PointExclusionViolation:
                    subtype = .pointExclusion
                case is CountryBorderCrossingViolation:
                    subtype = .countryBorderCrossing
                default:
                    fatalError("Unrecognized RouteLeg notification subtype encoding.")
                }
                try container.encode(subtype, forKey: .subtype)
            }
        }
    }
}

extension RouteLeg.Notification {
    
    public class Violation: Codable, ForeignMemberContainerClass {
        public var foreignMembers: JSONObject = [:]
        
        enum CodingKeys: String, CodingKey, CaseIterable {
            case message
        }
        
        /// The optional message of the notification
        public fileprivate(set) var message: String?
    }
    
    public final class MaxHeightViolation: Violation {
        enum CodingKeys: String, CodingKey, CaseIterable {
            case requestedValue = "requested_value"
            case actualValue = "actual_value"
            case unit
            case message
        }
        
        private let unit = "meters"
        /// The optional requested value in the request.
        public let requestedValue: Measurement<UnitLength>?
        /// The optional actual value associated with the property of the road
        public let actualValue: Measurement<UnitLength>?
                
        required public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            _ = try container.decode(String.self, forKey: .unit) // potentially not needed?
            
            let requestedValue = try container.decode(Double.self, forKey: .requestedValue)
            let actualValue = try container.decode(Double.self, forKey: .actualValue)
            self.requestedValue = Measurement(value: requestedValue, unit: UnitLength.meters)
            self.actualValue = Measurement(value: actualValue, unit: UnitLength.meters)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(unit, forKey: .unit)
            try container.encodeIfPresent(requestedValue?.converted(to: .meters).value, forKey: .requestedValue)
            try container.encodeIfPresent(actualValue?.converted(to: .meters).value, forKey: .actualValue)
            
            try super.encode(to: encoder)
        }
    }
    
    public final class MaxWidthViolation: Violation {
        enum CodingKeys: String, CodingKey, CaseIterable {
            case requestedValue = "requested_value"
            case actualValue = "actual_value"
            case unit
            case message
        }
        
        private let unit = "meters"
        
        /// The optional requested value in the request.
        public let requestedValue: Measurement<UnitLength>?
        /// The optional actual value associated with the property of the road
        public let actualValue: Measurement<UnitLength>?
                
        required public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            _ = try container.decode(String.self, forKey: .unit) // potentially not needed?
            
            let requestedValue = try container.decode(Double.self, forKey: .requestedValue)
            let actualValue = try container.decode(Double.self, forKey: .actualValue)
            self.requestedValue = Measurement(value: requestedValue, unit: UnitLength.meters)
            self.actualValue = Measurement(value: actualValue, unit: UnitLength.meters)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(unit, forKey: .unit)
            try container.encodeIfPresent(requestedValue?.converted(to: .meters).value, forKey: .requestedValue)
            try container.encodeIfPresent(actualValue?.converted(to: .meters).value, forKey: .actualValue)
            
            try super.encode(to: encoder)
        }
    }
    
    public final class MaxWeightViolation: Violation {
        enum CodingKeys: String, CodingKey, CaseIterable {
            case requestedValue = "requested_value"
            case actualValue = "actual_value"
            case unit
            case message
        }
        
        private let unit = "metric tons"
        
        /// The optional requested value in the request.
        public let requestedValue: Measurement<UnitMass>?
        /// The optional actual value associated with the property of the road
        public let actualValue: Measurement<UnitMass>?
        
        required public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            _ = try container.decode(String.self, forKey: .unit) // potentially not needed?
            
            let requestedValue = try container.decode(Double.self, forKey: .requestedValue)
            let actualValue = try container.decode(Double.self, forKey: .actualValue)
            self.requestedValue = Measurement(value: requestedValue, unit: UnitMass.metricTons)
            self.actualValue = Measurement(value: actualValue, unit: UnitMass.metricTons)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(unit, forKey: .unit)
            try container.encodeIfPresent(requestedValue?.converted(to: .metricTons).value, forKey: .requestedValue)
            try container.encodeIfPresent(actualValue?.converted(to: .metricTons).value, forKey: .actualValue)
            
            try super.encode(to: encoder)
        }
    }
    
    public final class UnpavedRoadViolation: Violation {
        enum CodingKeys: String, CodingKey, CaseIterable {
            case requestedValue = "requested_value"
            case actualValue = "actual_value"
            case message
        }
        
        /// The optional requested value in the request.
        public let requestedValue: String?
        /// The optional actual value associated with the property of the road
        public let actualValue: String?
        
        required public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.requestedValue = try container.decode(String.self, forKey: .requestedValue)
            self.actualValue = try container.decode(String.self, forKey: .actualValue)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(requestedValue, forKey: .requestedValue)
            try container.encodeIfPresent(actualValue, forKey: .actualValue)
            
            try super.encode(to: encoder)
        }
    }
    
    public final class PointExclusionViolation: Violation { }
    public final class CountryBorderCrossingViolation: Violation { }
}
