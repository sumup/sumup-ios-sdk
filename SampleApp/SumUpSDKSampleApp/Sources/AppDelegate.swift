import SumUpSDK

/**
 Application delegate containing SumUp SDK setup.
 
 # SumUp SDK Interaction
 
 ## SDK Setup
 Initialize the SDK with your affiliate key.
 
 See ``application(_:didFinishLaunchingWithOptions:)``
 */
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
            /*
             *   Logs integration warnings in non-production code. Do not call this method in
             *   release builds.
             */
            SumUpSDK.testIntegration()
        #endif

        /*
         *   This will setup the SumUpSDK.
         *
         *   You might consider moving this to a later point in your application's lifecycle,
         *   as this will start updating for locations.
         *
         *   Also remember to provide the necessary usage descriptions in your info.plist
         *   and to properly localize it, see:
         *   https://developer.sumup.com/terminal-payments/sdks/ios-sdk#add-property-list-keys-to-project
         *
         *   Ensure to add the Bundle Identifier of your iOS app to your 
         *   API Key's Application identifiers in the SumUp developer portal.
         */
        SumUpSDK.setup(affiliateKey: "c5e0068f-b776-4fa3-9051-f6f448e1a66d")
        return true
    }

}
