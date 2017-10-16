//
//  Router+Settings.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension MainRouter {
    
    func showSettingsView() {
        let router = SettingsRouter(mainRouter: self)
        router.run()
    }
    
    func showCurrencySettingsView() {
        let router = SettingsCurrencyRouter(mainRouter: self)
        router.run()
    }
    
    func showCommissionSettingsView() {
        let router = SettingsCommissionRouter(mainRouter: self)
        router.run()
    }
    
    func showPasswordSettingsView() {
        let router = SettingsPasswordRouter(mainRouter: self)
        router.run()
    }
    
    func showRestoreSettingsView(with info: SettingsRestoreVM.Info) {
        let router = SettingsRestoreRouter(mainRouter: self, info: info, icloudProvider: application.iCloud, defaultsProvider: application.defaults)
        router.run()
    }
    
    func showAboutSettingsView() {
        let router = SettingsAboutRouter(mainRouter: self)
        router.run()
    }
}
