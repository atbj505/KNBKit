Pod::Spec.new do |s|

  s.name         = "KNBKit"
  s.version      = "0.0.1"
  s.summary      = "Develop Kit for Dengyun"
  s.homepage     = "hhttps://github.com/atbj505/KNBKit"
  s.license      = "MIT"
  s.author       = { "atbj505" => "atbj505@hotmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/atbj505/KNBKit.git", :commit => "8155953a887fefbe3a18bf5163bcb7dd87814cad" }
  s.source_files  = "KNBKit/KNBKit/Source/**/*.{h,m}"
  # s.public_header_files = "KNBKit/Source/**/*.h"

  s.frameworks            = 'XCTest'
  s.user_target_xcconfig  = { 'FRAMEWORK_SEARCH_PATHS' => '$(PLATFORM_DIR)/Developer/Library/Frameworks' }
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  
  s.dependency "YTKNetwork"
  s.dependency "Mantle"
  s.dependency "MagicalRecord"
  s.dependency "libextobjc"
  s.dependency "Masonry"
  s.dependency "SDWebImage"
  s.dependency "LLSimpleCamera"
end
