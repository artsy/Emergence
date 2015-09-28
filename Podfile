platform :ios, '9.0'
platform :tvos, '9.0'

use_frameworks!

plugin 'cocoapods-expert-difficulty'
plugin 'cocoapods-keys', {
    :project => "Emergence",
    :targets => "Emergence",
    :keys => [
        "ArtsyAPIClientSecret",
        "ArtsyAPIClientKey",
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
  pod 'Moya/RxSwift'
  pod 'RxSwift', :git => "https://github.com/orta/RxSwift.git", :branch => "tvos"
  pod 'RxCocoa', :git => "https://github.com/orta/RxSwift.git", :branch => "tvos"
  pod 'SDWebImage'
end

def platform_pods()
  pod 'Artsy+Authentication', :git => "https://github.com/artsy/Artsy-Authentication.git", :branch => "tvos"
end

target 'Emergence' do
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
