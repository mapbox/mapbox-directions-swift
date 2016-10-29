use_frameworks!

def shared_pods
  pod 'Polyline', '~> 3.3'
end

def shared_test_pods
  shared_pods
  pod 'OHHTTPStubs/Swift', '~> 5.0', :configurations => ['Debug']
end

def shared_example_pods
  shared_pods
  pod 'Mapbox-iOS-SDK', '~> 3.3'
end

target 'MapboxDirections' do
  platform :ios, '8.0'
  shared_pods
end

target 'MapboxDirectionsTests' do
  platform :ios, '8.0'
  shared_test_pods
end

target 'MapboxDirectionsMac' do
  platform :osx, '10.10'
  shared_pods
end

target 'MapboxDirectionsMacTests' do
  platform :osx, '10.10'
  shared_test_pods
end

target 'MapboxDirectionsTV' do
  platform :tvos, '9.0'
  shared_pods
end

target 'MapboxDirectionsTVTests' do
  platform :tvos, '9.0'
  shared_test_pods
end

target 'MapboxDirectionsWatch' do
  platform :watchos, '2.0'
  shared_pods
end

target 'Example (Swift)' do
  platform :ios, '8.0'
  shared_example_pods
end

target 'Example (Objective-C)' do
  platform :ios, '8.0'
  shared_example_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
      
      cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
      cflags << '-fembed-bitcode'
      config.build_settings['OTHER_CFLAGS'] = cflags
    end
  end
end
