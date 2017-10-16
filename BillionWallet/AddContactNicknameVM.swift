//
//  AddContactVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol AddContactNicknameVMDelegate: class {
    func showContactCard(for user: UserData)
}

class AddContactNicknameVM {
    
    weak var delegate: AddContactNicknameVMDelegate?
    weak var apiProvider: API?
    
    var searchString: String?
    
    init(apiProvider: API) {
        self.apiProvider = apiProvider
    }
    
    func searchUser() {
        
        guard let nickname = searchString else {
            return
        }
        
        apiProvider?.findUser(nickname: nickname) { [weak self] result in
            switch result {
            case .success(let userData):
                self?.delegate?.showContactCard(for: userData)
            case .failure:
                let popup = PopupView(type: .cancel, labelString: "Nickname not found")
                UIApplication.shared.keyWindow?.addSubview(popup)
            }
        }
    }
    
}
