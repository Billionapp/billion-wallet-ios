//
//  ClearCodeModalView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class ExitModalView: UIView {
    
    typealias LocalizedStrings = Strings.Exit
    
    private let viewModel: SettingsVM
    @IBOutlet private weak var exitWalletLabel: UILabel! {
        didSet {
            exitWalletLabel.text = LocalizedStrings.title
        }
    }
    @IBOutlet private weak var exitHintLabel: UILabel! {
        didSet {
            exitHintLabel.text = LocalizedStrings.hint
        }
    }
    @IBOutlet private weak var clearIcloudLabel: UILabel! {
        didSet {
            clearIcloudLabel.text = LocalizedStrings.clearIcloud
        }
    }
    @IBOutlet private weak var exitButton: UIButton! {
        didSet {
            exitButton.setTitle(LocalizedStrings.exitButton, for: .normal)
        }
    }
    @IBOutlet private weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle(LocalizedStrings.cancelButton, for: .normal)
        }
    }
    @IBOutlet private weak var clearCloudSwitch: UISwitch!
    private weak var router: MainRouter?
    private weak var view: UIView!

    init(viewModel: SettingsVM, router: MainRouter, backImage: UIImage?) {
        self.viewModel = viewModel
        super.init(frame: UIScreen.main.bounds)
        self.view = fromNib()
        self.router = router
        
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = backImage
        self.insertSubview(imageView, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func exitAction() {
        let clearCloud = clearCloudSwitch.isOn
        viewModel.clearAll(clearCloud: clearCloud)
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
