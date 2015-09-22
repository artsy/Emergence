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

def app_pods()
  pod 'Artsy+UIColors', :git => "https://github.com/artsy/Artsy-UIColors.git", :branch => "tvos"
  pod 'Artsy+UILabels', :git => "https://github.com/artsy/Artsy-UILabels.git"

  # TODO: Update OSS Fonts for tvOS?
  if ENV['ARTSY_STAFF_MEMBER'] != nil || ENV['CI'] != nil
    pod 'Artsy+UIFonts', :git => "https://github.com/artsy/Artsy-UIFonts.git", :branch => "old_fonts_new_lib_tv"
  else
    pod 'Artsy+OSSUIFonts'
  end

  pod 'Gloss'
end

def platform_pods()
  pod 'Artsy+Authentication', :git => "https://github.com/artsy/Artsy-Authentication.git", :branch => "tvos"
  pod 'Hyperdrive'
end

target 'Emergence' do
  app_pods
  platform_pods
end

target 'EmergenceTests' do
    platform_pods
end
