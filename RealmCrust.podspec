#
# Be sure to run `pod lib lint Crust.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RealmCrust"
  s.version          = "0.0.2"
  s.summary          = "Simple Crust Extension for Mapping Realm Objects From JSON"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  Simple Crust Extension for Mapping Realm Objects From JSON. Use to easily map to/from JSON/Realm Objects.
                       DESC

  s.homepage         = "https://github.com/rexmas/RealmCrust"
  s.license          = 'MIT'
  s.author           = { "rexmas" => "rex.fenley@gmail.com" }
  s.source           = { :git => "https://github.com/rexmas/RealmCrust.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.dependency 'Crust'
  s.dependency 'RealmSwift'
  s.source_files = 'RealmCrust/**/*.swift'
  s.resource_bundles = {
  }

end
