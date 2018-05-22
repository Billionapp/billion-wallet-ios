//
//  ShopVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol ShopVMDelegate: class {

}

class ShopVM {

    weak var delegate: ShopVMDelegate?
    
    private let shops: [Shop]

    init(shopsFactory: ShopsFactoryProtocol) {
        shops = shopsFactory.getShops()
    }
    
    func getShopsCount() -> Int {
        return shops.count
    }
    
    func shop(at index: Int) -> Shop {
        return shops[index]
    }

}
