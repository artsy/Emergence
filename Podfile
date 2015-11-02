platform :ios, '9.0'
platform :tvos, '9.0'

use_frameworks!

plugin 'cocoapods-expert-difficulty'
plugin 'cocoapods-keys', {
    :project => "Emergence",
    :targets => "Artsy Shows",
    :keys => [
        "ArtsyAPIClientSecret",
        "ArtsyAPIClientKey",
        "SegmentDevWriteKey",
        "SegmentProductionWriteKey"
    ]
}

def artsy_pods()
    pod 'Artsy+UIColors', :git => "https://github.com/artsy/Artsy-UIColors.git", :branch => "tvos"
    pod 'Artsy+UILabels', :git => "https://github.com/artsy/Artsy-UILabels.git"

    # TODO: Update OSS Fonts for tvOS?
    if ENV['ARTSY_STAFF_MEMBER'] != nil || ENV['CI'] != nil
        pod 'Artsy+UIFonts', :git => "https://github.com/artsy/Artsy-UIFonts.git", :branch => "old_fonts_new_lib_tv"
    else
        pod 'Artsy+OSSUIFonts'
    end
end

def app_pods()
  pod 'Gloss'

  pod 'Alamofire', "~> 2.0"
  pod 'Moya/RxSwift'
  pod 'RxSwift', :git => "https://github.com/orta/RxSwift.git", :branch => "tvos"
  pod 'RxCocoa', :git => "https://github.com/orta/RxSwift.git", :branch => "tvos"
  pod 'SDWebImage'
  pod 'ARCollectionViewMasonryLayout'
  pod 'UIImageViewAligned', :git => "https://github.com/dbachrach/UIImageViewAligned.git"

  pod 'Analytics', :subspecs => ["Segmentio"]
  pod 'ARAnalytics', :subspecs => ["Segmentio"], :git => "https://github.com/orta/ARAnalytics.git"
end

def platform_pods()
  pod 'Artsy+Authentication', :git => "https://github.com/artsy/Artsy-Authentication.git", :branch => "tvos"
end

target 'Artsy Shows' do
  artsy_pods
  app_pods
  platform_pods
end

target 'EmergenceTests' do
    pod 'FBSnapshotTestCase'
    pod 'Nimble-Snapshots'
    pod 'Quick'
    pod 'Nimble', '= 2.0.0-rc.3'
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
