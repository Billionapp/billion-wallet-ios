//
//  AddContactViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AddContactViewController: BaseViewController<AddContactVM> {
    
    typealias LocalizedStrings = Strings.AddContact
    
    weak var router: MainRouter?
    var loader: LoaderView?
    fileprivate var titledView: TitledView!
    
    @IBOutlet weak var findingLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var scanBillionCodeButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var helperView: UIView!
    @IBOutlet weak var loaderView: UIView!
    
    override func configure(viewModel: AddContactVM) {
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.isHidden = true
        helperView.isHidden = false
        setupTitledView()
        localize()
        viewModel.addContactProvider.checkBletooth()
        NotificationCenter.default.addObserver(self, selector: #selector(removeLoader), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(initLoader), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLoader()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loader?.removeFromSuperview()
    }
    
    @objc func removeLoader() {
        loader?.removeFromSuperview()
    }
    
    @objc func initLoader() {
        self.addLoader()
    }
    
    // MARK: - Private methods
    fileprivate func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        titledView.subtitle = LocalizedStrings.subtitle
        titledView.closePressed = {
            self.navigationController?.pop()
        }
        view.addSubview(titledView)
    }
    
    private func localize() {
        findingLabel.text = LocalizedStrings.finding
        hintLabel.text = LocalizedStrings.hint
        scanBillionCodeButton.setTitle(LocalizedStrings.scanButton, for: .normal)
    }
    
    fileprivate func addLoader() {
        let size = loaderView.frame.size
        loader = LoaderView(size: size)
        loader?.backgroundColor = .clear
        loaderView.addSubview(loader!)
    }
    
    // MARK: - Actions
    @IBAction func scanBillionCodeButton(_ sender: UIButton) {
        router?.showScanView(resolver: viewModel.qrResolver!)
    }
}

// MARK: - AddContactVMDelegate

extension AddContactViewController: AddContactVMDelegate {
    
    func addContactProviderReadyForSearch() {
        searchView.isHidden = false
        helperView.isHidden = true
        viewModel.addContactProvider.start()
    }
    
    func didReceive(_ contact: ContactProtocol) {
        let back = captureScreen(view: view)
        router?.showAddContactCardView(contact: contact, back: back)
    }
    
    func didFailed(with error: Error) {
        Logger.error(error.localizedDescription)
    }
    
    func didRecognize(billionCode: String) {
        router?.showSearchContactView(back: backImage ?? captureScreen(view: view), billionCode: billionCode)
    }
}
