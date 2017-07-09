Pod::Spec.new do |s|
  s.name         = 'SumupSDK'
  s.version      = '2.3'
  s.summary      = 'Native iOS SDK for SumUp integration.'
  s.description  = <<-DESC
      Provides a native iOS SDK that enables you to integrate SumUp's proprietary
       card terminal(s) and its payment platform to accept credit and debit card
       payments (incl. VISA, MasterCard, American Express and more). SumUp's SDK
       communicates transparently to the card terminal(s) via Bluetooth (BLE 4.0)
       or an audio cable connection.
                   DESC

  s.homepage     = 'https://github.com/sumup/sumup-ios-sdk'
  s.license      = { :type => 'Commercial', :file => 'LICENSE' }
  s.author       = { 'SumUp' => 'integration@sumup.com' }

  s.platform     = :ios, '6.0'
  s.source       = { :git => 'https://github.com/sumup/sumup-ios-sdk.git', :tag => "v#{s.version}" }

  s.frameworks   = 'Accelerate', 'AVFoundation', 'Foundation', 'MapKit', 'UIKit'

  s.public_header_files = 'SumupSDK.embeddedframework/SumupSDK.framework/Versions/A/Headers/*.h'
  s.source_files = 'SumupSDK.embeddedframework/SumupSDK.framework/Versions/A/Headers/*.h'
  s.vendored_frameworks = 'SumupSDK.embeddedframework/SumupSDK.framework'
  s.resources    = 'SumupSDK.embeddedframework/Resources/SMPSharedResources.bundle', 'SumupSDK.embeddedframework/Resources/YTLibResources.bundle'

  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
end
