//
//  ObjectStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol FailureTxAsyncStorageProtocol: class {
    func getFailureTx(identifier: String, completion: @escaping (String) -> Void, failure: @escaping (Error) -> Void)
    func getFailureTx(url: URL, completion: @escaping (String) -> Void, failure: @escaping (Error) -> Void)
    func saveFailureTx(identifier: String, jsonString: String, completion: @escaping () -> Void, failure: @escaping (Error) -> Void)
    func deleteFailureTx(identifier: String, completion: @escaping () -> Void, failure: @escaping (Error) -> Void)
    func getListFailureTx(_ completion: @escaping ([URL]) -> Void, failure: @escaping (Error) -> Void)
}

protocol FailureTxStorageProtocol: class {
    func getFailureTx(identifier: String) throws -> String
    func getFailureTx(url: URL) throws -> String
    func saveFailureTx(identifier: String, jsonString: String) throws
    func deleteFailureTx(identifier: String) throws
    func getListFailureTx() throws -> [URL]
}
