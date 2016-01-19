# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!

def shared_pods
  pod 'RealmSwift'
end

target 'RealmCrust' do
  shared_pods
  link_with 'RealmCrust'
end

target 'RealmCrustTests' do
  shared_pods
  pod 'Crust'
  link_with 'RealmCrustTests'
end
