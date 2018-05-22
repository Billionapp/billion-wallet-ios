//
//  SettingsAboutViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsAboutViewController: BaseViewController<SettingsAboutVM> {
    
    typealias LocalizedStrings = Strings.Settings.About
    
    fileprivate var titledView: TitledView!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var seedCreationTitleLable: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var seedCreationTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        localize()
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        let distribution = dictionary["APP_DISTRIBUTION_TYPE"] as! String
        seedCreationTimeLabel.text = viewModel.seedCreationTime()
        versionLabel.text = String(format: LocalizedStrings.versionFormat, version, build, distribution)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeSwipeDownGesture()
        navigationController?.addSwipeDownPop()
    }
    
    @IBAction func followOnTwitter(_ sender: Any) {
        viewModel.openTwitter()
        
    }
    @IBAction func openBillionSite(_ sender: UIButton) {
        viewModel.openBillionSite()
    }
    
    private func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        titledView.closePressed = { [weak self] in
            self?.navigationController?.pop()
        }
        view.addSubview(titledView)
    }
    
    private func localize() {
        twitterLabel.text = LocalizedStrings.twitter
        seedCreationTitleLable.text = LocalizedStrings.seedCreationTime
    }
}
