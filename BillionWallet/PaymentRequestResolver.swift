//
//  PaymentRequestResolver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PaymentRequestResolver: SchemeResolverProtocol {
    private let handler: BitcoinUrlHandlerProtocol
    private let parser: BitcoinSchemeParserProtocol
    
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
