//
//  TransactionsDataManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import AudioToolbox

class TxsDataManager: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var viewModel: GeneralVM!
    private let fiatConverter: FiatConverter
    
    init(viewModel: GeneralVM, fiatConverter: FiatConverter) {
        self.viewModel = viewModel
        self.fiatConverter = fiatConverter
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TxCell", for: indexPath) as! TxCell
        let transaction = viewModel.filteredItems[indexPath.row]
        cell.configure(with: transaction, fiatConverter: fiatConverter)
        cell.delegate = viewModel.cellDelegate
        
        if let contact = transaction.connection {
            if let imageFromCache = viewModel.imageCache.object(forKey: contact.displayName as NSString) {
                cell.contactImageView.image = imageFromCache
            } else {
                DispatchQueue.global().async { [weak self] in
                    let image = contact.avatarImage
                    self?.viewModel.imageCache.setObject(image, forKey: contact.displayName as NSString)
                    DispatchQueue.main.async {
                        cell.contactImageView.image = image
                    }
                }
            }
        } else {
            cell.contactImageView.image = #imageLiteral(resourceName: "QRIcon")
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.delegate?.scrollViewDidScroll(scrollView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView.contentOffset.y != collectionView.contentSize.height - collectionView.frame.size.height + collectionView.contentInset.bottom else { return }
        viewModel.tapticService.selectionTaptic(capability:
            collectionView.traitCollection.forceTouchCapability == .available)
    }
}
