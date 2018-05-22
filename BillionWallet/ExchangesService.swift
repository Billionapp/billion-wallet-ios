//
//  ExchangesService.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ExchangesService: ExchangesServiceProtocol {
    
    let state: ExchangeState
    let network: Network
    let mapper: ExchangesMapperProtocol
    
    init(network: Network, mapper: ExchangesMapperProtocol, state: ExchangeState) {
        self.network = network
        self.mapper = mapper
        self.state = state
    }
    
    func getState() -> ExchangeState {
        return state
    }
    
    func getExchanges(completion: @escaping (Result<[Exchange]>) -> Void) {
        let request = NetworkRequest(method: .GET , path: "/exchanges/\(state.country)")
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                let data = json.arrayValue
                let exchanges = data.map { Exchange(json: $0) }
                completion(.success(exchanges))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getExchangeRates(ids: [String], completion: @escaping (Result<[String: Rates]>) -> Void) {
        let request = NetworkRequest(method: .POST, path: "/exchanges/rates", body: ids)
        network.makeRequest(request) { [unowned self] (result: Result<JSON>) in
            switch result {
            case .success(let json):
                let dict = self.mapper.map(json)
                completion(.success(dict))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
