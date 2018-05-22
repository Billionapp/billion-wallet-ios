//
//  ShopViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ShopViewController: BaseViewController<ShopVM>, UICollectionViewDelegate, UICollectionViewDataSource {
    
    typealias LocalizedString = Strings.Shop
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
    private var titledView: TitledView!
    
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }
    
    weak var router: MainRouter?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollection()
        setupBalance()
        setupTitledView()
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - Private methods
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedString.title
        view.addSubview(titledView)
    }
    
    private func setupCollection() {
        collectionView.register(UINib(nibName: "ShopCell", bundle: nil), forCellWithReuseIdentifier: "ShopCell")
        let top = Layout.model.topContentInsets
        let bottom = balanceViewContainer.bounds.height + Layout.model.spacing
        collectionView.contentInset = UIEdgeInsets(top: top, left: Layout.model.spacing/2, bottom: bottom, right: Layout.model.spacing/2)
    }
    
    private func setupBalance() {
        billionBalanceView.frame =  balanceViewContainer.bounds
        balanceViewContainer.addSubview(billionBalanceView)
        billionBalanceView.yourBalanceLabel.text = LocalizedString.balanceToSpend
    }
    
    private func showAlert(with shop: Shop) {
        let alert = UIAlertController(title: LocalizedString.alertTitle, message: LocalizedString.alertMessage, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: LocalizedString.ok, style: .default) { action in
            let url = URL(string: shop.link)!
            let safari = SafariViewContoller(url: url)
            safari.modalPresentationCapturesStatusBarAppearance = true
           self.present(safari, animated: true, completion: nil)
        }
        alert.addAction(ok)
        
        let cancel = UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getShopsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCell", for: indexPath) as! ShopCell
        let shop = viewModel.shop(at: indexPath.row)
        cell.configure(with: shop)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let shop = viewModel.shop(at: indexPath.row)
        showAlert(with: shop)
    }

}
