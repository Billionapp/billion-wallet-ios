//
//  ConfirmationMinutesFormatter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol MinutesFormatter {
    func stringForMinutes(_ minutes: Int) -> String
}

class ConfirmationMinutesFormatter: MinutesFormatter {
    typealias LocalizedStrings = Strings.Formatter
    
    private let formatter: DateComponentsFormatter
    
    init() {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.hour, .minute]
        self.formatter = formatter
    }
    
    func stringForMinutes(_ minutes: Int) -> String {
        let minutes = formatter.string(from: Double(minutes*60) as TimeInterval) ?? "NaN"
        return String(format: LocalizedStrings.confifmationMinutesFormat, minutes)
    }
}
