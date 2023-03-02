Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "MapboxDirections-pre"
  s.version      = "2.11.0-alpha.1"
  s.summary      = "Mapbox Directions API wrapper for Swift."

  s.description  = <<-DESC
  MapboxDirections makes it easy to connect your iOS, macOS, tvOS, or watchOS application to the Mapbox Directions API. Quickly get driving, cycling, or walking directions, whether the trip is nonstop or it has multiple stopping points, all using a simple interface reminiscent of MapKit’s `MKDirections` API. The Mapbox Directions API is powered by the OSRM routing engine and open data from the OpenStreetMap project.
                   DESC

  s.homepage     = "https://www.mapbox.com/navigation/"
  s.documentation_url = "https://docs.mapbox.com/ios/api/directions/"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = { :type => "ISC", :file => "LICENSE.md" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = { "Mapbox" => "mobile@mapbox.com" }
  s.social_media_url   = "https://twitter.com/mapbox"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  #  When using multiple platforms
  s.ios.deployment_target = "12.0"
  s.osx.deployment_target = "10.14"
  s.watchos.deployment_target = "5.0"
  s.tvos.deployment_target = "12.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source       = { :git => "https://github.com/mapbox/mapbox-directions-swift.git", :tag => "v#{s.version.to_s}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = ["Sources/MapboxDirections", "Sources/MapboxDirections/*/*"]

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true
  s.module_name = "MapboxDirections"
  s.swift_version = "5.5"

  s.dependency "Polyline", "~> 5.0"
  s.dependency "Turf", "~> 2.6.1"

end
