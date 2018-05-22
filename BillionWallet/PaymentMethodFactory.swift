//
//  BuySourceFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PaymentMethodFactory {
    
    func getPaymentMethods() -> [PaymentMethod] {
        do {
            let path = Bundle.main.path(forResource: "payment_methods", ofType: "json")!
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: [.alwaysMapped])
            let dict = try JSONDecoder().decode([String: String].self, from: data)
            let methods = dict.map { PaymentMethod(symbol: $0.key, name: $0.value) }
            return methods
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
