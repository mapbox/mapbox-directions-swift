#if !os(Linux)
@testable import MapboxDirections
import Turf
#if canImport(CoreLocation)
import CoreLocation
#endif

final class CustomIsochroneOptions: IsochroneOptions {
    var customParameters: [URLQueryItem]

    init(
        centerCoordinate: LocationCoordinate2D,
        contours: Contours,
        profileIdentifier: ProfileIdentifier,
        customParameters: [URLQueryItem] = []
    ) {
        self.customParameters = customParameters

        super.init(centerCoordinate: centerCoordinate, contours: contours, profileIdentifier: profileIdentifier)
    }

    override var urlQueryItems: [URLQueryItem] {
        var combined = super.urlQueryItems
        combined.append(contentsOf: customParameters)
        return combined
    }
}
#endif
