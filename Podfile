source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

# install! 'cocoapods', :deterministic_uuids => false

# Yep.
inhibit_all_warnings!

# Note: These should be reflected _accurately_ in the environment of
#       the continuous build server.

plugin 'cocoapods-keys', {
    :project => "Artsy",
    :target => "Artsy",
    :keys => [
        "ArtsyAPIClientSecret",
        "ArtsyAPIClientKey",
        "ArtsyFacebookAppID",
        "ArtsyTwitterKey",
        "ArtsyTwitterSecret",
        "ArtsyTwitterStagingKey",
        "ArtsyTwitterStagingSecret",
        "SegmentProductionWriteKey",
        "SegmentDevWriteKey",
        "AdjustProductionAppToken",
        "ArtsyEchoProductionToken",
    ]
}

target 'Artsy' do

  # Networking
  pod 'AFNetworking', "~> 2.5"
  pod 'AFOAuth1Client', :git => "https://github.com/lxcid/AFOAuth1Client.git", :tag => "0.4.0"
  pod 'AFNetworkActivityLogger'
  pod 'SDWebImage', '>= 3.7.2' # 3.7.2 contains a fix that allows you to not force decoding each image, which uses lots of memory

  # Core

  # This is used once on the inquiryVC, could be pulled out
  pod 'ALPValidator'

  pod 'ARGenericTableViewController', :git => 'https://github.com/orta/ARGenericTableViewController.git'
  pod 'CocoaLumberjack', :git => 'https://github.com/CocoaLumberjack/CocoaLumberjack.git' # Unreleased > 2.0.1 version has a CP modulemap fix
  pod 'FLKAutoLayout', :git => 'https://github.com/alloy/FLKAutoLayout.git', :branch => 'add-support-for-layout-guides-take-2'
  pod 'FXBlurView'
  pod 'iRate'
  pod 'ISO8601DateFormatter', :git => "https://github.com/orta/iso-8601-date-formatter"
  pod 'JLRoutes', :git => 'https://github.com/orta/JLRoutes.git'
  pod 'JSBadgeView'
  pod 'JSDecoupledAppDelegate'
  pod 'Mantle', '~> 1.5.6'
  pod 'MMMarkdown'
  pod 'NPKeyboardLayoutGuide'
  pod 'ReactiveCocoa'
  pod 'UICKeyChainStore'
  pod 'MARKRangeSlider'
  pod 'EDColor'

  # Core owned by Artsy
  pod 'ARTiledImageView', :git => 'https://github.com/dblock/ARTiledImageView'
  pod 'ORStackView', :git => 'https://github.com/1aurabrown/ORStackView.git'
  pod 'UIView+BooleanAnimations'
  pod 'NAMapKit', :git => 'https://github.com/neilang/NAMapKit'
  pod 'Aerodramus', :git => 'https://github.com/artsy/Aerodramus.git', :branch => 'tests'

  # Custom CollectionView Layouts
  pod 'ARCollectionViewMasonryLayout', :git => 'https://github.com/ashfurrow/ARCollectionViewMasonryLayout', :branch => "modern"

  # Deprecated:
  # UIAlertView is deprecated for iOS8 APIs
  pod 'UIAlertView+Blocks'

  # Language Enhancments
  pod 'KSDeferred'
  pod 'MultiDelegate'
  pod 'ObjectiveSugar'

  # Artsy Spec repo stuff
  pod 'Artsy-UIButtons'
  pod 'Artsy+UIColors'
  pod 'Artsy+UILabels'

  if ENV['ARTSY_STAFF_MEMBER'] != nil || ENV['CI'] != nil
    pod 'Artsy+UIFonts', :git => "https://github.com/artsy/Artsy-UIFonts.git"
  else
    pod 'Artsy+UIFonts'
  end

  # Facebook
  pod 'FBSDKCoreKit', '4.9.0-beta2'
  pod 'FBSDKLoginKit', '4.9.0-beta2'

  # Analytics
  pod 'Analytics'
  pod 'ARAnalytics', :git=> "https://github.com/orta/ARAnalytics.git", :commit => "6f31b5c7bcbd59d4dac7e92e215d3c2c22f3400e", :subspecs => ["Segmentio", "HockeyApp", "Adjust", "DSL"]

  # Developer Pods
  pod 'DHCShakeNotifier'
  pod 'ORKeyboardReactingApplication'
  pod 'VCRURLConnection'

  # Easter Eggs
  pod 'ARASCIISwizzle'
  pod 'DRKonamiCode'

  # Swift pods 🎉
  pod 'Then'
  pod 'Interstellar/Core'
  pod 'Socket.IO-Client-Swift'

end

target 'Artsy Tests' do
  pod 'FBSnapshotTestCase', git: 'https://github.com/untitledstartup/ios-snapshot-test-case.git'
  pod 'Expecta+Snapshots'
  pod 'OHHTTPStubs'
  pod 'XCTest+OHHTTPStubSuiteCleanUp'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'Forgeries/Mocks', :git => "https://github.com/ashfurrow/Forgeries.git", :branch => "application"

  # Swift pods 🎉
  pod 'Quick', git: 'https://github.com/Quick/Quick.git'
  pod 'Nimble', git: 'https://github.com/Quick/Nimble.git'
  pod 'Nimble-Snapshots', '~> 3.0.0'
end


post_install do |installer|
  # Disable bitcode for now. Specifically needed for HockeySDK and ARAnalytics.
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end

  # CI was having trouble shipping signed builds
  # https://github.com/CocoaPods/CocoaPods/issues/4011
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end


  app_plist = "Artsy/App_Resources/Artsy-Info.plist"
  plist_buddy = "/usr/libexec/PlistBuddy"
  version = `#{plist_buddy} -c "Print CFBundleShortVersionString" #{app_plist}`.strip
  installer.pods_project.targets.each do |target|
    `#{plist_buddy} -c "Set CFBundleShortVersionString #{version}" "Pods/Target Support Files/#{target}/Info.plist" > /dev/null 2>&1`
  end

  # TODO:
  # * ORStackView: Move Laura's changes into master and update
  # * Send PRs for the rest
  %w(
    Pods/ORStackView/Classes/ios/ORStackView.h
    Pods/ARAnalytics/ARAnalytics.h
    Pods/ARTiledImageView/Classes/ARTiledImageViewDataSource.h
    Pods/DRKonamiCode/Sources/DRKonamiGestureRecognizer.h
    Pods/NAMapKit/NAMapKit/*.h
  ).flat_map { |x| Dir.glob(x) }.each do |header|
    addition = "#import <UIKit/UIKit.h>\n"
    contents = File.read(header)
    unless contents.include?(addition)
      File.open(header, "w") do |file|
        file.puts addition
        file.puts contents
      end
    end
  end
end
