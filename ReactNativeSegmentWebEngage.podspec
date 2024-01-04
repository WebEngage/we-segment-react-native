require 'json'
package = JSON.parse(File.read('package.json'))

Pod::Spec.new do |s|
  s.name                = "ReactNativeSegmentWebEngage"
  s.version             = package["version"]
  s.description         = package["description"]
  s.summary             = <<-DESC
                            A RN
                          DESC
  s.homepage            = "https://www.webengage.com"
  s.license             = package['license']
  s.authors             = "WebEngage Inc."
  s.source              = {:file => './' }
  s.platform            = :ios, "11.0"
  s.dependency          'React'
  s.dependency          'WebEngage'
  s.source_files        = 'ios/WebEngageSegmentReactBridge/WebEngageSegmentReactBridge/**/*.{h,m}'
  
end
