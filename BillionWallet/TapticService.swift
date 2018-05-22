//
//  TapticService.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import AudioToolbox

protocol TapticProtocol {
    func selectionTaptic(capability: Bool)
}

class TapticService: TapticProtocol {
    
    let selectionGenerator: UISelectionFeedbackGenerator
    
    init() {
        selectionGenerator = UISelectionFeedbackGenerator()
        selectionGenerator.prepare()
    }
    
    func selectionTaptic(capability: Bool) {
        DispatchQueue.main.async {
            if capability {
                self.selectionGenerator.selectionChanged()
                self.selectionGenerator.prepare()
            } else {
                AudioServicesPlaySystemSound(.peek)
            }
        }
    }
}
