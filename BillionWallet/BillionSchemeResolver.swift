//
//  BillionSchemeResolver.swift
//  BillionWallet
//
//  Created by Evolution Group on 20.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class BillionSchemeResolver: SchemeResolverProtocol {
    private let parser: BillionSchemeParserProtocol
    private let handler: BillionUrlHandlerProtocol
    
    init(billionParser: BillionSchemeParserProtocol, billionHandler: BillionUrlHandlerProtocol) {
        self.handler = billionHandler
        self.parser = billionParser
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
