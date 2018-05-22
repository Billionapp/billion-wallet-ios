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
    var app: Application! 

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Logger.configureFileLogging()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.app = Application(window:window)
        self.window = window
        self.app.mainRouter.run()
        #if DEBUG
            let watermarkView = UIView(frame: window.bounds)
            watermarkView.isUserInteractionEnabled = false
            let watermarkText = UILabel(frame: CGRect(x: 0, y: window.bounds.midY, width: 400, height: 100))
            watermarkText.text = NSLocalizedString("DEBUG", value: "DEBUG", comment: "DEBUG")
            watermarkText.font = UIFont.boldSystemFont(ofSize: 100)
            watermarkText.textColor = UIColor.gray.withAlphaComponent(0.3)
            watermarkText.isUserInteractionEnabled = false
            watermarkView.addSubview(watermarkText)
            window.addSubview(watermarkView)
        #endif
        if !app.walletProvider.noWallet {
            app.authChecker.ensureAuthIsOk()
        }
        // FIXME: Temporary solution should be removed from here. 
        let defaults = UserDefaults.standard
        let lastSync = defaults.double(forKey: "LastSyncProgress")
        app.walletProvider.lastSyncCache = lastSync

        // iCloud: - clear icloud
        //app.iCloud.deleteFilesInDirectory(url: ICloud.DocumentsDirectory.iCloudDocumentsURL!)
         
        if app.keychain.pin != nil {
            app.lockProvider.autolock()
        }
        
        let pushProvider = app.notificationProvider
        pushProvider.configure(application: application)
                
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        app.defaults.apnsToken = deviceToken
        if !app.walletProvider.noWallet {
            app.taskQueueProvider.addOperation(type: .pushConfig)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.error(error.localizedDescription)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let defaults = UserDefaults.standard
        let lastSync = app.walletProvider.lastSyncCache
        defaults.set(lastSync, forKey: "LastSyncProgress")
        defaults.synchronize()
        Logger.flushFileBuffer()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        app.blurLocker.addBlur()
        Logger.flushFileBuffer()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if !(app.feeProvider.isFired()) {
            app.feeProvider.fireTimer()
        }
        if app.keychain.pin != nil {
            app.lockProvider.autolock()
        }
        app.mainRouter.navigationController.popToRootViewController(animated: false)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        app.blurLocker.removeBlur()
        app.groupRequestRestoreProvider.restoreFromBackup()
    }
}

//MARK: - QuickAction
extension AppDelegate {
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(shouldPerformActionFor(shortcutItem: shortcutItem))
    }
    
    private func shouldPerformActionFor(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard !app.walletProvider.noWallet else {
            return false
        }
        
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = ShortcutIdentifier(identifier: shortcutType) else {
            return false
        }
        
        return handleAction(shortcutIdentifier: shortcutIdentifier)
    }
    
    private func handleAction(shortcutIdentifier: ShortcutIdentifier) -> Bool {
        switch shortcutIdentifier {
        case .OpenReceive:
            self.app.mainRouter.showReceiveView(back: #imageLiteral(resourceName: "background_black"))
            return true
        case .OpenSend:
            self.app.mainRouter.showChooseReceiver(back: #imageLiteral(resourceName: "background_black"), conveyor: TouchConveyorView())
            return true
        }
    }
}

//MARK: - URL Scheme
extension AppDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let factory = UrlSchemeResolverFactory(userPaymentRequestProvider: self.app.userPaymentRequestProvider,
                                               router: self.app.mainRouter,
                                               accountProvider: self.app.accountProvider,
                                               walletProvider: self.app.walletProvider)
        
        let resolver = factory.createUrlSchemeResolver(from: url)
        resolver.resolve(url)
        return true
    }
}

enum ShortcutIdentifier: String {
    case OpenReceive
    case OpenSend
    
    init?(identifier: String) {
        guard let shortIdentifier = identifier.components(separatedBy: ".").last else {
            return nil
        }
        self.init(rawValue: shortIdentifier)
    }
}

