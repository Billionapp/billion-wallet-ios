//
//  ClearCodeModalView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

// @deadpool
// TODO: Make buttons 'delete' and 'cancel' localizable
final class ArchiveModalView: UIView {
    typealias LocalizedStrings = Strings.ContactCard
    
    private weak var viewModel: ContactCardVM!
    private weak var router: MainRouter?
    
    @IBOutlet private weak var deleteLabel: UILabel!

    init(viewModel: ContactCardVM, router: MainRouter) {
        super.init(frame: UIScreen.main.bounds)
        self.viewModel = viewModel
        self.router = router
        
        fromNib()
        addBlur()

        let name = viewModel.displayName
        deleteLabel.text = String(format: LocalizedStrings.deleteLabel, name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func deleteAction() {
        viewModel?.archiveContact()
        router?.navigationController.pop()
        close()
    }
    
    @IBAction func cancelAction() {
        close()
    }
    
    func close() {
        self.removeFromSuperview()
    }
}
