//
//  TimeProfiler.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

var t: TimeProfiler = TimeProfiler()

class TimeProfiler {
    private var reason: String = ""
    private var startDate: Date = Date.distantPast
    private var timePoints: [(mark: String, date: Date)] = []
    
    init() { }
    
    func start(reason: String = "Time Measurement") {
        self.reason = reason
        self.startDate = Date()
    }
    
    func addPoint(mark: String) {
        let point = (mark: mark, date: Date())
        self.timePoints.append(point)
    }
    
    func reset() {
        reason = ""
        startDate = Date.distantPast
        timePoints = []
    }
    
    func printResults() {
        var printString = ""
        printString.append("[TimeProfiler] \(reason):\n")
        var lastDate = startDate
        for point in timePoints.enumerated() {
            let time = point.element.date.timeIntervalSince1970 - lastDate.timeIntervalSince1970
            printString.append("\t[\(point.offset)] \(point.element.mark): \(time)\n")
            lastDate = point.element.date
        }
        Logger.debug(printString)
    }
}
