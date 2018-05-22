//
//  HistoryDisplayable.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum SortPriority: Int {
    case lowest
    case low
    case normal
    case high
    case highest
}

extension SortPriority: Equatable {
    static func ==(lhs: SortPriority, rhs: SortPriority) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension SortPriority: Comparable {
    static func <(lhs: SortPriority, rhs: SortPriority) -> Bool {
        // Lowest priority will appear later than highest priority
        return lhs.rawValue > rhs.rawValue
    }
}

protocol HistoryDisplayable {
    var identity: String { get }
    var stateHash: String { get }
    var connection: ContactProtocol? { get }
    var header: String { get }
    var title: String { get }
    var rawAmount: UInt64 { get }
    var subtitle: String { get }
    var interaction: InteractionType { get }
    var bubbleImage: UIImage { get }
    var time: Date { get }
    var sortPriority: SortPriority { get }
    func showDetails(visitor: HistoryDisplayableVisitor, cellY: CGFloat, backImage: UIImage)
    
    static func ==(_ lhs: HistoryDisplayable, _ rhs: HistoryDisplayable) -> Bool
}

extension HistoryDisplayable {
    static func ==(_ lhs: HistoryDisplayable, _ rhs: HistoryDisplayable) -> Bool {
        if lhs.identity.hashValue != rhs.identity.hashValue {
            return false
        } else {
            return lhs.identity == rhs.identity
                && lhs.stateHash == rhs.stateHash
        }
    }
}

enum InteractionType {
    case timestamp(timestamp: String)
    case interaction(icon: UIImage)
}
