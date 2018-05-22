//
//  HistoryUpdater.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12.03.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class HistoryDisplayableHashable: Hashable {
    var item: HistoryDisplayable
    
    init(_ item: HistoryDisplayable) {
        self.item = item
    }
    
    var hashValue: Int {
        return item.identity.hashValue
    }
    
    static func ==(lhs: HistoryDisplayableHashable, rhs: HistoryDisplayableHashable) -> Bool {
        return lhs.item.identity == rhs.item.identity
    }
}

class HistoryUpdater {
    var batchInsertIndexes: IndexSet
    var batchUpdateIndexes: IndexSet
    var batchDeletedIndexes: IndexSet
    
    var updateCount: Int {
        return batchInsertIndexes.count
            + batchUpdateIndexes.count
            + batchDeletedIndexes.count
    }
    
    var oldState: [HistoryDisplayable] = []
    var newState: [HistoryDisplayable] = []
    
    init() {
        self.batchInsertIndexes = []
        self.batchUpdateIndexes = []
        self.batchDeletedIndexes = []
    }
    
    func configureUpdate(fromState historyItemsPre: [HistoryDisplayable], toState historyItemsPost: [HistoryDisplayable]) {
        batchDeletedIndexes.removeAll()
        batchInsertIndexes.removeAll()
        batchUpdateIndexes.removeAll()
        
        oldState = historyItemsPre
        newState = historyItemsPost
        
        let old: Set<HistoryDisplayableHashable> = Set(historyItemsPre.map { HistoryDisplayableHashable($0) })
        let new: Set<HistoryDisplayableHashable> = Set(historyItemsPost.map { HistoryDisplayableHashable($0) })
        
        // compute inserts/deletes based on soft hash value (identifier)
        let inserted = new.subtracting(old)
        let deleted = old.subtracting(new)
        
        // compute updates based on state hashes
        let oldStates = Set(old.subtracting(deleted).map { $0.item.stateHash })
        let newStates = Set(new.subtracting(inserted).map { $0.item.stateHash })
        let updateStates = newStates.subtracting(oldStates)
        
        if deleted.count > 0 {
            for (i, item) in historyItemsPre.enumerated() {
                let contains = deleted.contains { $0.item.identity == item.identity }
                if contains {
                    batchDeletedIndexes.insert(i)
                }
            }
        }
        
        if inserted.count > 0 {
            for (i, item) in historyItemsPost.enumerated() {
                let contains = inserted.contains { $0.item.identity == item.identity }
                if contains {
                    batchInsertIndexes.insert(i)
                }
            }
        }
        
        if updateStates.count > 0 {
            for (i, item) in historyItemsPost.enumerated() {
                let contains = updateStates.contains { item.stateHash == $0 }
                if contains {
                    batchUpdateIndexes.insert(i)
                }
            }
        }
    }
    
    func configureUpdateByIndexes(indexes: IndexSet) {
        batchDeletedIndexes.removeAll()
        batchInsertIndexes.removeAll()
        batchUpdateIndexes.removeAll()
        
        batchUpdateIndexes = indexes
    }
}
