//
//  ExchangesServiceFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum ExchangeState: String {
    
    typealias LocalizedString = Strings.Buy
    
    case ru
    case en
    
    var country: String {
        return self.rawValue
    }
    
    var currency: String {
        switch self {
        case .en:
            return "USD"
        case .ru:
            return "RUB"
        }
    }
    
    var isMethodButtonEnabled: Bool {
        switch self {
        case .en:
            return false
        case .ru:
            return true
        }
    }
    
    var buyLabel: String {
        switch self {
        case .en:
            return LocalizedString.currentTitle
        case .ru:
            return LocalizedString.buyTitle
        }
    }
    
    var sellLabel: String {
        switch self {
        case .en:
            return "-"
        case .ru:
            return LocalizedString.sellTitle
        }
    }
}

class ExchangesServiceFactory {
    
    let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func create() -> ExchangesServiceProtocol {
        let locale = Locale.current.regionCode?.lowercased() ?? "en"
        let state = ExchangeState(rawValue: locale) ?? .en
        
        switch state {
        case .en:
            let mapper = ExchangesEuMapper(country: state.country, currency: state.currency)
            let service = ExchangesService(network: network, mapper: mapper, state: state)
            return service
        case .ru:
            let mapper = ExchangesRuMapper(country: state.country, currency: state.currency)
            let service = ExchangesService(network: network, mapper: mapper, state: state)
            return service
        }
        
    }
    
}
