Pod::Spec.new do |s|
  # XCFramework support first came in 1.9.0.beta.1
  s.cocoapods_version = '>= 1.9'

  s.name    = 'SumUpSDK'
  s.version = '6.0.0'
  s.summary = "This SDK enables you to integrate SumUp's proprietary card terminal(s) and its payment platform to accept credit and debit card payments."

  s.description = <<-DESC
  	This SDK enables you to integrate SumUp's proprietary card terminal(s) and its payment platform to accept credit and debit card payments (incl. VISA, MasterCard, American Express and more). SumUp's SDK communicates transparently to the card terminal(s) via Bluetooth (BLE 4.0) or an audio cable connection. Upon initiating a checkout, the SDK guides your user using appropriate screens through each step of the payment process. As part of the process, SumUp also provides the card terminal setup screen, along with the cardholder signature verification screen. The checkout result is returned with the relevant data for your records.
  DESC

  s.homepage         = 'https://github.com/sumup/sumup-ios-sdk'
  s.social_media_url = 'https://twitter.com/SumUp'
  s.license          = { file: 'LICENSE', type: 'Proprietary' }
  s.author           = { 'SumUp' => 'integration@sumup.com' }

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  # This source is only used when the pod is specified by name in the trunk register.
  # If you specify a specific tag/branch/path in the Podfile during development, this
  # source is ignored.
  s.source = { git: 'https://github.com/sumup/sumup-ios-sdk.git', tag: "v#{s.version}" }

  s.vendored_frameworks = 'SumUpSDK.xcframework'
  s.platform            = :ios, '14.0'
end
