//
//  ClearCodeModalView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class ArchiveModalView: UIView {
    
    fileprivate weak var viewModel: ContactCardVM?
    fileprivate weak var router: MainRouter?
    
    @IBOutlet fileprivate weak var deleteLabel: UILabel?

    init(viewModel: ContactCardVM, router: MainRouter) {
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        addBlur()
        self.viewModel = viewModel
        self.router = router
        
        let name = viewModel.contact.displayName
        deleteLabel?.text = String(format: "Delete contact %@?", name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func deleteAction() {
        do {
            try viewModel?.archiveContact()
        } catch {
            print(error.localizedDescription)
        }
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
