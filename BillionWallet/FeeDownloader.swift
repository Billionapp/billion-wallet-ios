//
//  FeeDownloader.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol FeeDownloader {
    func downloadFee(_ completion: @escaping (JSON) -> Void, failure: @escaping (Error) -> Void)
}
