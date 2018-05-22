//
//  MigrationViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class MigrationViewController: BaseViewController<MigrationVM> {
    @IBOutlet weak var progressView: UIProgressView!
    
    weak var router: MainRouter?
    
    override func configure(viewModel: MigrationVM) {
        super.configure(viewModel: viewModel)
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.isHidden = true
        self.viewModel.startMigration()
    }
    
    // MARK: - Private methods
    
    // MARK: - Actions

}

// MARK: - MigrationVMDelegate

extension MigrationViewController: MigrationVMDelegate {
    
    func didChangeProgress(_ value: Float) {
        progressView.isHidden = false
        progressView.setProgress(value, animated: true)
    }
    
    func didFinishMigration() {
        progressView.isHidden = true
        self.router?.showStartScreen()
    }
    
}
