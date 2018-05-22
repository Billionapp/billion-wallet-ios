//
//  PrivacyVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 4/10/18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol PrivacyVMDelegate: class {
    func didFinish()
}

class PrivacyVM {

    weak var delegate: PrivacyVMDelegate?

    init() {

    }

}
