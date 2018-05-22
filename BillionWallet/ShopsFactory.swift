//
//  ShopsFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ShopsFactory: ShopsFactoryProtocol {
    
    func getShops() -> [Shop] {
        do {
            let path = Bundle.main.path(forResource: "Shops", ofType: "json")!
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: [.alwaysMapped])
            let shops = try JSONDecoder().decode(FailableCodableArray<Shop>.self, from: data)
            return shops.elements
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
