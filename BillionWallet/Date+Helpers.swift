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
    
        let dateFormatter = CombineDateFormatter()
        dateFormatter.locale = Locale.current
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale.current
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        return dateFormatter.string(from: self)+"\n"+timeFormatter.string(from: self)
    }
    
    class CombineDateFormatter: DateFormatter {
        private let dayInterval: TimeInterval = 24*60*60
        
        var otherFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.locale = self.locale
            formatter.setLocalizedDateFormatFromTemplate("dMMM")
            return formatter
        }
        var todayFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.locale = self.locale
            formatter.dateStyle = .short
            formatter.doesRelativeDateFormatting = true
            return formatter
        }
        
        override func string(from date: Date) -> String {
            if calendar.isDateInYesterday(date) ||
                calendar.isDateInToday(date) ||
                calendar.isDateInTomorrow(date) {
                return todayFormatter.string(from: date)
            } else {
                return otherFormatter.string(from: date)
            }
        }
    }

}
