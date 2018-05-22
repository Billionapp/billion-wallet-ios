//
//  MessageWrapper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class MessageWrapper: MessageWrapperProtocol {
    
    func wrap(_ dataJson: JSON, type: MessageType) throws -> Data {
        let json: [String: Any] = ["data": dataJson.dictionaryValue, "type": type.rawValue]
        return try JSON(json).rawData()
    }
    
    func unwrap(_ data: Data) throws -> (type: MessageType, json: JSON) {
        let json = JSON(data)
        guard let rawType = json["type"].string else {
            throw MessageWrapperError.noType
        }
        guard let type = MessageType(rawValue: rawType) else {
            throw MessageWrapperError.invalidType
        }
        let unwraped = json["data"]
        return (type, unwraped)
    }

}

enum MessageWrapperError: Error {
    case noType
    case invalidType
    
    var errorDescription: String? {
        switch self {
        case .noType:
            return "Coudn't retrive type from response"
        case .invalidType:
            return "Retrived type is invalid"
        }
    }
}
