platform :ios, '8.0'
use_frameworks!

def shared_pods
  pod 'Polyline', '~> 3.0'
end

target 'MapboxDirections' do
  shared_pods
end

target 'MapboxDirectionsTests' do
  pod 'Nocilla'
  shared_pods
end

target 'Directions Example' do
    shared_pods
end
