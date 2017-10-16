//
//  AppDelegate.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    @objc
    var app: Application?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.app = Application(window:window)
        self.window = window
        self.app?.mainRouter.run()
        
        let defaults = UserDefaults.standard
        let lastSync = defaults.double(forKey: "LastSyncProgress")
        if lastSync != 0 {
            BRPeerManager.sharedInstance()?.lastSyncCache = lastSync
        }
        // iCloud: - clear icloud
//        ICloud().deleteFilesInDirectory(url: ICloud.DocumentsDirectory.iCloudDocumentsURL)
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let defaults = UserDefaults.standard
        let lastSync = BRPeerManager.sharedInstance()?.lastSyncCache
        defaults.set(lastSync, forKey: "LastSyncProgress")
        defaults.synchronize()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        app?.blurLocker.addBlur()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if !((app?.ratesProvider.isFired())! || (app?.feeProvider.isFired())!) {
            app?.ratesProvider.fireTimer()
            app?.feeProvider.fireTimer()
        }
        if app?.keychain.pin != nil && app?.lockProvider.shouldLock() == true {
            app?.keychain.isLocked = true
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        app?.blurLocker.removeBlur()
    }

}

