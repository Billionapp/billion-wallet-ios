//
//  BuyVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol BuyVMDelegate: class {
    func update()
    func didSelectPaymentMethod(_ method: PaymentMethod)
    func didReceiveState(_ state: ExchangeState)
}

class BuyVM {

    var models: [ExchangeModel] {
        let models = exchanges.enumerated().map { map -> ExchangeModel in
            let state = self.exchangesService.getState()
            return ExchangeModel(exchange: map.element, rates: rates[map.element.id], method: paymentMethod, state: state)
        }
        return models.filter { $0.method == paymentMethod }
    }
    
    var rates = [String: Rates]()
    
    var paymentMethod: PaymentMethod?
    private var exchanges =  [Exchange]()

    weak var delegate: BuyVMDelegate?
    
    private let exchangesService: ExchangesServiceProtocol

    init(exchangesService: ExchangesServiceProtocol) {
        self.exchangesService = exchangesService
    }
    
    func getAvailebleMethods() -> [String]? {
        var methods = Set<String>()
        for rate in rates.values {
            for b in rate.buy {
                methods.insert(b.method)
            }
            for s in rate.sell {
                methods.insert(s.method)
            }
        }
        
        if methods.isEmpty {
            return nil
        }
        
        return Array(methods)
    }
    
    func getState() {
        let state = exchangesService.getState()
        delegate?.didReceiveState(state)
    }
    
    func getExchanges() {
        exchangesService.getExchanges { [unowned self] result in
            switch result {
            case .success(let exchanges):
                self.exchanges = exchanges
                self.delegate?.update()
                let ids = exchanges.map { $0.id }
                self.exchangesService.getExchangeRates(ids: ids) { result in
                    switch result {
                    case .success(let rates):
                        self.rates = rates
                        self.delegate?.update()
                    case .failure(let error):
                        Logger.error("getExchangeRates failed with error: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                Logger.error("getExchanges failed with error: \(error.localizedDescription)")
            }
        }
    }

}

extension BuyVM: BuyPickerOutputDelegate {
    
    func didSelectPaymentMethod(_ method: PaymentMethod) {
        self.paymentMethod = method
        delegate?.didSelectPaymentMethod(method)
    }
    
}
