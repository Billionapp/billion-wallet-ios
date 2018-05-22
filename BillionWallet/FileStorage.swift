//
//  FileStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum StorageMessage {
    case add(filename: String)
    case remove(filename: String)
    case updateAll
}

class FileStorage: FileStorageProtocol {
    
    private let saveDir: URL
    private let fileManager: FileManager
    private var channel: Channel<StorageMessage>?
    
    init(saveDir: URL, fileManager: FileManager) {
        self.saveDir = saveDir
        self.fileManager = fileManager
        createSaveDirIfNeeded()
    }
    
    private func read(by path: URL) throws -> Data {
        let fileName = path.lastPathComponent
        return try read(by: fileName)
    }
    
    private func createSaveDirIfNeeded() {
        if !fileManager.fileExists(atPath: saveDir.path, isDirectory: nil) {
            try! fileManager.createDirectory(at: saveDir, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func setChannel(_ channel: Channel<StorageMessage>) {
        self.channel = channel
        channel.send(.updateAll)
    }
    
    func isExist(_ fileName: String) -> Bool {
        let filePath = saveDir.appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: filePath.path, isDirectory: nil)
    }
    
    func write(_ data: Data, with fileName: String) throws {
        let filePath = saveDir.appendingPathComponent("\(fileName)")
        do {
            try data.write(to: filePath, options: .atomic)
            channel?.send(.add(filename: fileName))
        } catch {
            throw FileStorageError.writeFailure(fileName)
        }
    }
    
    func read(by fileName: String) throws -> Data {
        let filePath = saveDir.appendingPathComponent("\(fileName)")
        do {
            return try Data(contentsOf: filePath)
        } catch {
            throw FileStorageError.readFailure("\(fileName)")
        }
    }
    
    func deleteData(by fileName: String) throws {
        guard isExist(fileName) else { return }
        let filePath = saveDir.appendingPathComponent(fileName)
        do {
            try fileManager.removeItem(atPath: filePath.path)
            channel?.send(.remove(filename: fileName))
        } catch {
            throw FileStorageError.removeFailure("\(fileName)")
        }
    }
    
    func listOfFiles() throws -> Set<String> {
        do {
            let fileUrls = try fileManager.contentsOfDirectory(at: saveDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return Set(fileUrls.map { $0.lastPathComponent })
        } catch {
            throw FileStorageError.failureContent(saveDir.lastPathComponent)
        }
    }
}

