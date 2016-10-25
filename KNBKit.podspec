Pod::Spec.new do |s|

  s.name         = "KNBKit"
  s.version      = "0.0.4"
  s.summary      = "Develop Kit for Dengyun"
  s.homepage     = "hhttps://github.com/atbj505/KNBKit"
  s.license      = "MIT"
  s.author       = { "atbj505" => "atbj505@hotmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/atbj505/KNBKit.git", :tag => s.version.to_s }
  s.source_files  = "KNBKit/KNBKit/Source/**/*.{h,m}"
  # s.public_header_files = "KNBKit/Source/**/*.h"
  
  s.dependency "YTKNetwork"
  s.dependency "Mantle"
  s.dependency "MagicalRecord"
  s.dependency "libextobjc"
  s.dependency "Masonry"
  s.dependency "SDWebImage"
  s.dependency "LLSimpleCamera", "~> 4.2.0"
  s.dependency "LCProgressHUD"
  s.dependency "MJRefresh"
end
