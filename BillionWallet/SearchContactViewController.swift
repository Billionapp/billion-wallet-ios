//
//  SearchContactViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class SearchContactViewController: BaseViewController<SearchContactVM> {
    
    typealias LocalizedStrings = Strings.SearchContact
    weak var router: MainRouter?
    fileprivate var titledView: TitledView!
    @IBOutlet weak var loaderView: UIView!
    var loader: LoaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitledView()
        viewModel.getUser()
    }
    
    override func configure(viewModel: SearchContactVM) {
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLoader()
        NotificationCenter.default.addObserver(self, selector: #selector(removeLoader), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(initLoader), name: .UIApplicationDidBecomeActive, object: nil)
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
}

//MARK: - Private methods
extension SearchContactViewController {
    fileprivate func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.titleAddContact
        titledView.subtitle = LocalizedStrings.subtitleSearchMode
        titledView.closePressed = {
            self.navigationController?.pop()
        }
        view.addSubview(titledView)
    }
    
    fileprivate func addLoader() {
        let size = loaderView.frame.size
        loader = LoaderView(size: size)
        loader?.backgroundColor = .clear
        loaderView.addSubview(loader!)
    }
}

//MARK: - SearchContactVMDelegate
extension SearchContactViewController: SearchContactVMDelegate {
    func userDidFound(user: ContactProtocol) {
        let back = captureScreen(view: view)
        router?.showAddContactCardView(contact: user, back: back)
    }
    
    func userNotFound(errorMessage: String) {
        let popup = PopupView(type: .cancel, labelString: errorMessage)
        UIApplication.shared.keyWindow?.addSubview(popup)
        navigationController?.pop()
    }
}
