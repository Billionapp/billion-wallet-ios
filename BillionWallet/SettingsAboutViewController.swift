//
//  SettingsAboutViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsAboutViewController: BaseViewController<SettingsAboutVM> {
    
    fileprivate var titledView: TitledView!
    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        versionLabel.text = "\(version) build \(build)"
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = "About"
        titledView.closePressed = { [weak self] in
            self?.navigationController?.pop()
        }
        view.addSubview(titledView)
    }

}
