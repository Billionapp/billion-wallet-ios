//
//  AboutVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 3/19/18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol AboutVMDelegate: class {
    func didFinishAbout()
}

class AboutVM {

    weak var delegate: AboutVMDelegate?

    init() {

    }

}
