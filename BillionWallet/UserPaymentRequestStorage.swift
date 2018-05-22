//
//  UserPaymentRequestStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

private let filePostfix = ".userpaymentrequest.json"

class UserPaymentRequestStorage: UserPaymentRequestStorageProtocol {
    private let fileManager: FileManager
    private let storageURL: URL
    
    init(fileManager: FileManager,
         storageUrl: URL) {
        
        self.storageURL = storageUrl
        self.fileManager = fileManager
    }
    
    func getUserPaymentRequest(identifier: String,
                              completion: @escaping (String) -> Void,
                              failure: @escaping (Error) -> Void) {
        
        let fileName = "\(identifier)\(filePostfix)"
        let url = storageURL.appendingPathComponent(fileName)
        do {
            let jsonString = try String(contentsOf: url)
            completion(jsonString)
        } catch let error {
            failure(error)
        }
    }
    
    func getUserPaymentRequest(url: URL,
                               completion: @escaping (String) -> Void,
                               failure: @escaping (Error) -> Void) {
        
        do {
            let jsonString = try String(contentsOf: url)
            completion(jsonString)
        } catch let error {
            failure(error)
        }
    }
    
    func saveUserPaymentRequest(identifier: String,
                       jsonString: String,
                       completion: @escaping () -> Void,
                       failure: @escaping (Error) -> Void) {
        
        do {
            let fileName = "\(identifier)\(filePostfix)"
            let url = storageURL.appendingPathComponent(fileName)
            let jsonData = jsonString.data(using: .utf8)
            let string = String(data: jsonData!, encoding: .utf8)
            if fileManager.fileExists(atPath: url.absoluteString) {
                try fileManager.removeItem(at: url)
                try string?.write(to: url, atomically: false, encoding: .utf8)
            } else {
                try string?.write(to: url, atomically: false, encoding: .utf8)
            }
            completion()
        } catch let error {
            failure(error)
        }
    }
    
    func getListUserPaymentRequest(_ completion: @escaping ([URL]) -> Void, failure: @escaping (Error) -> Void) {//+
        do {
            let items = try FileManager.default.contentsOfDirectory(at: storageURL,
                                                                    includingPropertiesForKeys: [],
                                                                    options: .skipsSubdirectoryDescendants)
            var objects: Array<URL> = []
            for item in items {
                if item.lastPathComponent.contains(filePostfix) {
                    objects.append(item.absoluteURL)
                }
            }
            completion(objects)
        } catch let error {
            failure(error)
        }
    }
    
    func deleteUserPaymentRequest(identifier: String,
                                  completion: @escaping () -> Void,
                                  failure: @escaping (Error) -> Void)  {
        
        do {
            let fileName = "\(identifier)\(filePostfix)"
            let url = storageURL.appendingPathComponent(fileName)
            try fileManager.removeItem(at: url)
            completion()
        } catch let error {
            failure(error)
        }
    }
    
    func changeStateToRejected(identifier: String,
                               completion: @escaping () -> Void,
                               failure: @escaping (Error) -> Void)  {
        
        do {
            let fileName = "\(identifier)\(filePostfix)"
            let url = storageURL.appendingPathComponent(fileName)
            let _ = try String(contentsOf: url)
            completion()
        } catch let error {
            failure(error)
        }
    }
}

