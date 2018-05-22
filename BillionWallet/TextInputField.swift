//
//  TextInputField.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01.03.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct TextInputField {
    var commentInput: Bool = false
    private var commentText: String = ""
    
    mutating func setCommentText(_ str: String) {
        commentText = str
    }
    
    func getCommentText() -> String {
        guard commentInput else { return "" }
        return commentText
    }
}
