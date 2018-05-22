//
//  BWalletManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol BWalletManager: class {
    var noWallet: Bool { get }
    var seedPhrase: String? { get }
    var seedCreationTime: TimeInterval { get }
    var isTestnet: Bool { get }
    func generateRandomSeed() -> String?
    func recoverWallet(withPhrase phrase: String) throws
}
