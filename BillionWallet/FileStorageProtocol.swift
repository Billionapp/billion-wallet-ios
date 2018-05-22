//
//  FileStorageProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol FileStorageProtocol {
    func setChannel(_ channel: Channel<StorageMessage>)
    
    func isExist(_ fileName: String) -> Bool
    func write(_ data: Data, with fileName: String) throws
    func read(by fileName: String) throws -> Data
    func deleteData(by fileName: String) throws
    func listOfFiles() throws -> Set<String>
}

enum FileStorageError: LocalizedError {
    case writeFailure(String)
    case readFailure(String)
    case failureContent(String)
    case removeFailure(String)
    
    var errorDescription: String? {
        switch self {
        case .writeFailure(let fileName):
            return "Failure to write \(fileName)"
        case .readFailure(let fileName):
            return "Failure to read \(fileName)"
        case .failureContent(let dir):
            return "Failure to read content in directory: \(dir)"
        case .removeFailure(let fileName):
            return "Failure to read remove: \(fileName)"
        }
    }
}
