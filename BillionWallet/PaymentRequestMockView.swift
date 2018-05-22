//
//  PaymentRequestMockView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class PaymentRequestMockView: LoadableFromXibView {

    @IBAction func closePressed(_ sender: UIButton) {
        removeFromSuperview()
    }
    
}
