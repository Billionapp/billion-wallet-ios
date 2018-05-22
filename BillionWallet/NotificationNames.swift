//
//  NotificationNames.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd. on 23/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let walletBalanceChangedNotificationName = Notification.Name("BRWalletBalanceChangedNotification")
    public static let walletSwitchCurrencyNotificationName = Notification.Name("walletSwitchCurrencyNotificationName")
    public static let walletRatesChangedNotificationName = Notification.Name("walletRatesChangedNotificationName")
    public static let syncStarted = Notification.Name("BRPeerManagerSyncStartedNotification")
}
