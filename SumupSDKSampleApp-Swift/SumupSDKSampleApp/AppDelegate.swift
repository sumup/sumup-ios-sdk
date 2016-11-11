//
//  AppDelegate.swift
//  SumupSDKSampleApp
//
//  Created by Felix Lamouroux on 10.11.16.
//  Copyright © 2016 SumUp Payments Limited. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /*
         *   This will setup the SumUpSDK
         *   You might consider moving this to a later point in your application's lifecycle,
         *   as this will start updating for locations.
         *   Also remember to provide the NSLocationUsageDescription key in your info.plist
         *   and to properly localize it.
         *
         *   Ensure to add the Bundle Identifier of your iOS app to your 
         *   API Key's Application identifiers in the developer portal.
         */

        SumupSDK.setup(withAPIKey: "c5e0068f-b776-4fa3-9051-f6f448e1a66d")
        return true
    }

}
