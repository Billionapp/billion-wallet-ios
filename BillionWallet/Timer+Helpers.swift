//
//  Timer+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Timer {
    
    class func createDispatchTimer(interval: DispatchTimeInterval,
                                   leeway: DispatchTimeInterval,
                                   deadline: DispatchTime = DispatchTime.now(),
                                   queue: DispatchQueue,
                                   block: @escaping ()->()) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0),
                                                   queue: queue)
        timer.schedule(deadline: deadline,
                       repeating: interval,
                       leeway: leeway)
        
        // Use DispatchWorkItem for compatibility with iOS 9. Since iOS 10 you can use DispatchSourceHandler
        let workItem = DispatchWorkItem(block: block)
        timer.setEventHandler(handler: workItem)
        timer.resume()
        return timer
    }
}
