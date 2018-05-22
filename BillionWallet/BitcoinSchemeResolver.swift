//
//  BitcoinSchemeResolver.swift
//  BillionWallet
//
//  Created by Evolution Group on 20.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol SchemeResolverProtocol {
    func resolve(_ url: URL)
}

class BitcoinSchemeResolver: SchemeResolverProtocol {
    private let parser: BitcoinSchemeParserProtocol
    private let handler: BitcoinUrlHandlerProtocol
    
    init(parser: BitcoinSchemeParserProtocol, handler: BitcoinUrlHandlerProtocol) {
        self.parser = parser
        self.handler = handler
    }
    
    func resolve(_ url: URL) {
        do {
            let data = try parser.parseUrl(url)
            handler.handle(urlData: data)
        } catch let err {
            let popup = PopupView(type: .cancel, labelString: err.localizedDescription)
            UIApplication.shared.keyWindow?.addSubview(popup)
        }
    }
}
