//
//  FailResolver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class FailResolver: SchemeResolverProtocol {
    
    private let reason: Reason
    
    enum Reason {
        case unknownUrl
        case noWallet
        
        var description : String {
            switch self {
            case .unknownUrl:
                return Strings.SchemeResolver.unknownUrl
            case .noWallet:
                return Strings.SchemeResolver.nowallet
            }
        }
    }
    
    init(reason: Reason) {
        self.reason = reason
    }
    
    func resolve(_ url: URL) {
        let popup = PopupView(type: .cancel, labelString: reason.description)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
}
