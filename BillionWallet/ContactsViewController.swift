//
//  ContactsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ContactsViewController: BaseViewController<ContactsVM> {
    
    @IBOutlet fileprivate weak var searchTextField: UITextField?
    @IBOutlet fileprivate weak var addButton: UIButton?
    @IBOutlet fileprivate weak var clearButton: UIButton?
    @IBOutlet fileprivate weak var contactsCollection: UICollectionView? {
        didSet {
            contactsCollection?.register(UINib(nibName: "ContactsCell".nibNameForCell(), bundle: nil), forCellWithReuseIdentifier: "ContactsCell")
        }
    }
    @IBOutlet fileprivate weak var cancelButtonConstraint: NSLayoutConstraint?
    var backForBlur: UIImage?
    weak var router: MainRouter?

    override func configure(viewModel: ContactsVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBlurBackground()
        configureSearchField()
        setCollectionDelegates()
        viewModel.initData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(icloudContactsDidSyncronize), name: .iCloudContactsDidFinishSyncronizationNotitfication, object: nil)
        
//        viewModel.addTestItems() //For init test data only
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func icloudContactsDidSyncronize() {
        viewModel.initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.initData()
    }
    
    func configureSearchField() {
        searchTextField?.layer.borderColor = UIColor.searchBarBorderColor().cgColor
        searchTextField?.layer.borderWidth = 2
        searchTextField?.layer.halfHeightCornerRadius()
        searchTextField?.layer.sublayerTransform = CATransform3DMakeTranslation(27, 0, 0);
        searchTextField?.delegate = viewModel
    }
    
    func setCollectionDelegates() {
        contactsCollection?.dataSource = viewModel
        contactsCollection?.delegate = viewModel
    }
    
    func setBlurBackground() {
        if let backImage = backForBlur {
            let imageView = UIImageView(image: backImage)
            view.insertSubview(imageView, at: 0)
        }
    }
    
    // MARK: Actions
    @IBAction func closeAction() {
        navigationController?.pop()
    }
    
    @IBAction func cancelSearch() {
        UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            self.cancelButtonConstraint?.constant = 0
        })
        searchTextField?.resignFirstResponder()
    }
    
    @IBAction func clearAction() {
        searchTextField?.text = ""
        viewModel.searchString = ""
    }
    
    @IBAction func addContactPressed(_ sender: UIButton) {
        router?.showAddContactTypeView()
    }
}

extension ContactsViewController: ContactsVMDelegate {
    
    func searchDidBegin(buttonWidth: CGFloat) {
        UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseIn, animations: { 
            self.cancelButtonConstraint?.constant = buttonWidth
        })
    }
    
    func searchStringDidChange(searchString: String) {
        if searchString == "" {
            clearButton?.isEnabled = false
        } else {
            clearButton?.isEnabled = true
        }
    }
    
    func filteredDidChanged(filteredArray: [ContactProtocol]) {
        self.contactsCollection?.reloadData()
    }
    
    func didSelectContact(_ contact: ContactProtocol) {
        router?.showContactCardView(contact: contact)
    }
    
    func didPickContact(_ contact: ContactProtocol) {
        navigationController?.pop()
    }
}

extension UIColor {
    class func searchBarBorderColor() -> UIColor {
        return UIColor.init(red: 116.0/255.0, green: 123.0/255.0, blue: 139.0/255.0, alpha: 1.0)
    }
}

