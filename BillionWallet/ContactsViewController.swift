//
//  ContactsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ContactsViewController: BaseViewController<ContactsVM> {
    
    typealias LocalizedStrings = Strings.Contacts
    
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var contactsCollection: UICollectionView!
    private var titledView: TitledView!
    private var topGradientView: UIView!
    private var bottomGradientView: UIView!
    
    private let gradientAreaPercent: CGFloat = 0.72
    
    var backForBlur: UIImage?
    weak var router: MainRouter?
    
    override func configure(viewModel: ContactsVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBlurBackground()
        setupCollectionView()
        viewModel.initData()
        viewModel.subscribe()
        setupTitledView()           
        localize()
        contactsCollection.addSubview(self.refreshControl)
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.clear
        return refreshControl
    }()
    
    fileprivate func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        titledView.closePressed = {
            self.navigationController?.pop()
        }
        view.addSubview(titledView)
    }
    
    private func localize() {
        addButton.setTitle(LocalizedStrings.addContact, for: .normal)
    }
    
    func setupCollectionView() {
        if #available(iOS 10.0, *) {
            contactsCollection.isPrefetchingEnabled = false
        }
        contactsCollection.register(UINib(nibName: "ContactsCell".nibNameForCell(), bundle: nil), forCellWithReuseIdentifier: "ContactsCell")
        contactsCollection.dataSource = viewModel
        contactsCollection.delegate = viewModel
        contactsCollection.emptyDataSetSource = viewModel
    }
    
    func setBlurBackground() {
        if let backImage = backForBlur {
            let imageView = UIImageView(image: backImage)
            view.insertSubview(imageView, at: 0)
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        navigationController?.pop()
        refreshControl.endRefreshing()
    }
    
    // MARK: Actions
    @IBAction func addContactPressed(_ sender: UIButton) {
        let image = captureScreen(view: view)
        router?.showAddContactView(back: image)
    }
}

extension ContactsViewController: ContactsVMDelegate {
    func contactsCountEqualZero(_ flag: Bool) {
        if flag {
            navigationController?.addSwipeDown()
        } else {
            removeSwipeDownGesture()
        }
    }
    
    func searchStringDidChange(searchString: String) {
        
    }
    
    func searchDidBegin(buttonWidth: CGFloat) {
        
    }
    
    func filteredDidChanged(filteredArray: [ContactProtocol]) {
        DispatchQueue.main.async {
            self.contactsCollection.reloadData()
        }
    }
    
    func didSelectContact(_ contact: ContactProtocol) {
        let back = captureScreen(view: view)
        router?.showContactCardView(contact: contact, back: back)
    }
    
    func didPickContact(_ contact: ContactProtocol) {
        navigationController?.pop()
    }
}
