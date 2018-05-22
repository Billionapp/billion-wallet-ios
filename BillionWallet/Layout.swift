//
//  Layout.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum Layout {
    case seven
    case sevenPlus
    case five
    case four
    case ten
    
    static var model: Layout {
        let height = UIScreen.main.bounds.size.height
        switch height {
        case 812:
            return .ten
        case 736:
            return .sevenPlus
        case 667:
            return .seven
        case 568:
            return .five
        default:
            return .sevenPlus
        }
    }
    
    var offset: CGFloat {
        switch self {
        case .seven, .ten:
            return 16
        case .sevenPlus:
            return 20
        case .five, .four:
            return 10
        }
    }
    
    var spacing: CGFloat {
        switch self {
        case .seven, .ten:
            return 12
        case .sevenPlus:
            return 16
        case .five, .four:
            return 10
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .seven, .ten:
            return 20
        case .sevenPlus:
            return 20
        case .five, .four:
            return 16
        }
    }
    
    var height: CGFloat {
        switch self {
        case .seven, .ten:
            return 59
        case .sevenPlus:
            return 62
        case .five, .four:
            return 52
        }
    }
    
    var topContentInsets: CGFloat {
        switch self {
        case .sevenPlus:
            return 50
        case .ten:
            return 35
        case .seven:
            return 45
        case .five, .four:
            return 45
        }
    }
    
    var contactCellHeight: CGFloat {
        switch self {
        case .seven, .ten:
            return 71
        case .sevenPlus:
            return 78
        case .five, .four:
            return 63
        }
    }
    
    var keyboardHeight: CGFloat {
        switch self {
        case .ten:
            return 291
        case .five, .seven:
            return 216
        case .sevenPlus:
            return 226
        case .four:
            return 216
        }
    }
    
    var emojiKeybordHeight: CGFloat {
        switch self {
        case .seven:
            return 258
        case .ten:
            return 333
        case .five:
            return 253
        case .sevenPlus:
            return 271
        case .four:
            return 253
        }
    }
}

