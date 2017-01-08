platform :tvos, "9.0"

use_frameworks!

plugin "cocoapods-keys", {
    project: "Emergence",
    targets: "Artsy Shows",
    keys: [
      "ArtsyAPIClientSecret",
      "ArtsyAPIClientKey",
      "SegmentDevWriteKey",
      "SegmentProductionWriteKey"
    ]
}

def artsy_pods
  pod "Artsy+UIColors", git: "https://github.com/artsy/Artsy-UIColors.git"
  pod "Artsy+UILabels", git: "https://github.com/artsy/Artsy-UILabels.git", branch: "master"

  # TODO: Update OSS Fonts for tvOS?
  if !ENV["ARTSY_STAFF_MEMBER"].nil? || !ENV["CI"].nil?
    pod "Artsy+UIFonts", git: "https://github.com/artsy/Artsy-UIFonts.git", branch: "old_fonts_new_lib_tv"
  else
    pod "Artsy+OSSUIFonts", git: "https://github.com/artsy/Artsy-OSSUIFonts"
  end
end

def app_pods
  pod "Gloss"

  pod "Alamofire"
  pod "Moya/RxSwift"
  pod "RxSwift"
  pod "SDWebImage"
  pod "ARCollectionViewMasonryLayout", git: "https://github.com/ashfurrow/ARCollectionViewMasonryLayout.git"
  pod "UIImageViewAligned", git: "https://github.com/orta/UIImageViewAligned.git"

  pod "NSURL+QueryDictionary", git: "https://github.com/orta/NSURL-QueryDictionary.git", branch: "develop"
  pod "Analytics", git: "https://github.com/orta/analytics-ios.git", branch: "orta-tvos"
  pod "ARAnalytics", subspecs: ["Segmentio"]
end

def platform_pods
  pod "Artsy+Authentication", subspecs: ["email"], git: "https://github.com/artsy/Artsy-Authentication.git", branch: "master"
end

target "Artsy Shows" do
  artsy_pods
  app_pods
  platform_pods
end

post_install do |installer|
  app_plist = "Emergence/Info.plist"
  plist_buddy = "/usr/libexec/PlistBuddy"
  version = `#{plist_buddy} -c "Print CFBundleShortVersionString" #{app_plist}`.strip
  puts "Updating CocoaPods' version numbers to #{version}"

  installer.pods_project.targets.each do |target|
    `#{plist_buddy} -c "Set CFBundleShortVersionString #{version}" "Pods/Target Support Files/#{target}/Info.plist"`
  end
end
