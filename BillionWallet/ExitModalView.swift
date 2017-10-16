//
//  ClearCodeModalView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class ExitModalView: UIView {
    
    fileprivate weak var viewModel: SettingsVM?
    fileprivate weak var router: MainRouter?

    init(viewModel: SettingsVM, router: MainRouter) {
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        addBlur()
        self.viewModel = viewModel
        self.router = router
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func exitAction() {
        viewModel?.clearAll()
        router?.showAddWalletView()
        close()
    }
    
    @IBAction func closeAction() {
        close()
    }
    
    func close() {
        self.removeFromSuperview()
    }
}
