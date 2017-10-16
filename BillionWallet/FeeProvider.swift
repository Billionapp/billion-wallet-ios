//
//  FeeProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class FeeProvider {
    weak var apiProvider: API?
    
    private var timer: Timer?
    fileprivate var cashForFee = [String: Fee]()
    
    init(apiProvider: API) {
        self.apiProvider = apiProvider
    }
    
    @objc func downloadFee() {
        self.apiProvider?.getFee(failure: { [weak self] (error) in
            self?.apiProvider?.getFeeFallBack(failure: { (error) in
                Logger.error(error.localizedDescription)
            }, completion: { (fee) in
                Logger.info("Success update cash fee (fall back)")
                self?.cashForFee = fee
            })
            }, completion: { (fee) in
                Logger.info("Success update cash fee")
                self.cashForFee = fee
        })
    }
    
    // Get fee for fee size except custom fee
    func getFee(size: FeeSize) -> Fee? {
        guard cashForFee.count != 0 else {return nil}
        switch size {
        case .high:
            return cashForFee[size.rawValue]
        case .normal:
            return cashForFee[size.rawValue]
        case .low:
            return cashForFee[size.rawValue]
        default:
            return nil
        }
    }
}

//MARK: - Timer
extension FeeProvider {
    
    func startTimer() {
        Logger.info("Fee timer is fired")
        downloadFee()
        timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(downloadFee), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        Logger.info("Fee timer stopped")
    }

    func isFired() -> Bool {
        guard let t = timer else {return false}
        return t.isValid
    }
    
    func fireTimer() {
        timer?.fire()
    }
}
