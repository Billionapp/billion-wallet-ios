//
//  Main.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02.10.17
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : nil
}

private let unsafeArgv = UnsafeMutableRawPointer(CommandLine.unsafeArgv)
    .bindMemory(
        to: UnsafeMutablePointer<Int8>.self,
        capacity: Int(CommandLine.argc))

UIApplicationMain(CommandLine.argc, unsafeArgv, nil, delegateClassName())
