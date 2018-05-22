//
//  PrivacyViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 4/10/18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: BaseViewController<PrivacyVM> {
    
    weak var router: MainRouter?
    typealias LocalizedStrings = Strings.Privacy

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWeb()
        addGradient()
        addButton()
        addGradientOnTop()
    }
    
    override func configure(viewModel: PrivacyVM) {
        super.configure(viewModel: viewModel)
        viewModel.delegate = self
    }
    
    private func setupWeb() {
        let webka = WKWebView(frame: UIScreen.main.bounds)
        webka.isOpaque = false
        webka.backgroundColor = UIColor.clear
        webka.scrollView.backgroundColor = UIColor.clear
        self.view.addSubview(webka)
        
        let reachability = Reachability.forInternetConnection()
        if reachability?.currentReachabilityStatus() == NotReachable {
            if let path = Bundle.main.path(forResource: "Privacy", ofType: "html") {
                let url = URL(fileURLWithPath: path)
                webka.loadFileURL(url, allowingReadAccessTo: url)
            }
        } else {
            webka.load(URLRequest(url: policyUrl()))
        }
    }
    
    private func policyUrl() -> URL {
        let avaliableLanguages = ["en","ch","it","hk","jp","ru"]
        if let code = Locale.current.collatorIdentifier?.components(separatedBy: "-").first {
            if avaliableLanguages.contains(code) {
                return URL(string: "http://billionapp.com/privacy_policy_\(code)")!
            }
        }
        return URL(string: "http://billionapp.com/privacy_policy_en")!
    }
    
    private func addGradient() {
        let gradHeight = Layout.model.height + Layout.model.offset * 3
        let frame = CGRect(x: 0,
                           y: UIScreen.main.bounds.size.height - gradHeight,
                           width: UIScreen.main.bounds.size.width,
                           height: gradHeight)
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor]
        self.view.layer.addSublayer(gradient)
    }
    
    private func addButton() {
        let frame = CGRect(x: Layout.model.offset,
                           y: UIScreen.main.bounds.size.height - Layout.model.height - Layout.model.offset,
                           width: UIScreen.main.bounds.size.width - 2 * Layout.model.offset,
                           height: Layout.model.height)
        let button = GradientButton(frame: frame)
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        button.setTitle(LocalizedStrings.buttonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        view.addSubview(button)
    }
    
    @objc private func done() {
        self.router?.navigationController.pop()
    }

}

extension PrivacyViewController: PrivacyVMDelegate {
    func didFinish() {}
}
