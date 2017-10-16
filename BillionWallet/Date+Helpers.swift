//
//  Date+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension Date {
    
    var humanReadable: String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM dd HH:mm"
        
        return formatter.string(from: self)
    }

}
