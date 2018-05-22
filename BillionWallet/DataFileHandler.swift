//
//  DataFileHandler.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol DataFileHandler {
    func write(_ data: Data, to url: URL) throws
    func read(from url: URL) throws -> Data
}

class StandardDataFileHandler: DataFileHandler {
    func write(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }
    
    func read(from url: URL) throws -> Data {
        let file = try FileHandle(forReadingFrom: url)
        defer {
            file.closeFile()
        }
        return file.readDataToEndOfFile()
    }
}
