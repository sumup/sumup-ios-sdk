Pod::Spec.new do |s|

  s.name    = "SumUpSDK"
  s.version = "3.1"
  s.summary = "This SDK enables you to integrate SumUp's proprietary card terminal(s) and its payment platform to accept credit and debit card payments."

  s.description = <<-DESC
  	This SDK enables you to integrate SumUp's proprietary card terminal(s) and its payment platform to accept credit and debit card payments (incl. VISA, MasterCard, American Express and more). SumUp's SDK communicates transparently to the card terminal(s) via Bluetooth (BLE 4.0) or an audio cable connection. Upon initiating a checkout, the SDK guides your user using appropriate screens through each step of the payment process. As part of the process, SumUp also provides the card terminal setup screen, along with the cardholder signature verification screen. The checkout result is returned with the relevant data for your records.
                    DESC

  s.homepage         = "https://github.com/sumup/sumup-ios-sdk"
  s.social_media_url = "https://twitter.com/SumUp"
  s.license          = { :file => "LICENSE", :type => "Proprietary" }
  s.author           = { "SumUp" => "integration@sumup.com" }

  # This source is only used when the pod is specified by name in the trunk register.
  # If you specify a specific tag/branch/path in the Podfile during development, this
  # source is ignored.
  s.source = { :git => "https://github.com/sumup/sumup-ios-sdk.git", :tag => "v#{s.version}" }

  # As we only provide a (static) framework and resources, but no source files, this SDK
  # will always be added to other projects as static library, and the resource bundles
  # will automatically be placed within the app bundle. CocoaPods will not generate a
  # static or dynamic wrapper library.
  s.vendored_frameworks = "SumUpSDK.embeddedframework/SumUpSDK.framework"
  s.resources = [
                "SumUpSDK.embeddedframework/Resources/SMPSharedResources.bundle"
                ]
  s.module_map = "SumUpSDK.embeddedframework/SumUpSDK.framework/Modules/module.modulemap"

  s.frameworks           = "Accelerate", "AVFoundation", "MapKit", "ExternalAccessory"
  s.user_target_xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }
  s.platform             = :ios, "9.0"

end
