//
//  AttachmentStorage.swift
//  B-App
//
//  Created by macbook on 21.06.17.
//  Copyright © 2017 Nikita. All rights reserved.
//

import Foundation

class AttachmentStorage {
    
    func store(url: URL, extension: String, completion: ((URL?, Error?) -> ())?) {
        // obtain path to temporary file
        let filename = ProcessInfo.processInfo.globallyUniqueString
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(filename).\(`extension`)")
        
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        // fetch attachment
        let task = session.dataTask(with: url) { (data, response, error) in
            let _ = try! data?.write(to: path)
            completion?(path, error)
        }
        task.resume()
    }
}
