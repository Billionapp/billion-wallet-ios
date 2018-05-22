//
//  SettingsAboutVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsAboutVM {
    
    private let homePageUrl = URL(string: "http://billionapp.com")!
    private let billionTwitterUrl = URL(string: "https://twitter.com/billionappl")!
    private let walletManager: BWalletManager
    
    init(walletManager: BWalletManager) {
        self.walletManager = walletManager
    }
    
    func openTwitter() {
        if UIApplication.shared.canOpenURL(billionTwitterUrl) {
            UIApplication.shared.open(billionTwitterUrl, completionHandler: nil)
        }
    }
    
    func openBillionSite() {
        if UIApplication.shared.canOpenURL(homePageUrl) {
            UIApplication.shared.open(homePageUrl, completionHandler: nil)
        }
    }
    
    func seedCreationTime() -> String {
        let creationTimestamp = walletManager.seedCreationTime
        let creationDate = Date(timeIntervalSinceReferenceDate: creationTimestamp)
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: creationDate)
    }
    
    
}
