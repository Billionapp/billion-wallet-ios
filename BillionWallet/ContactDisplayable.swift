//
//  ContactDisplayable.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol ContactDisplayable {
    var description: (value: String, type: String) { get }
    var givenName: String { get set }
    var sharingString: String { get }
}
