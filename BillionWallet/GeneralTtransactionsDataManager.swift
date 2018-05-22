//
//  GeneralTransactionsDataManager.swift
//  BillionWallet
//
//  Created by Artur Guseinov on 23/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GeneralTransactionsDataManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    weak var viewModel: GeneralVM!
    
    init(viewModel: GeneralVM) {
        self.viewModel = viewModel
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        let transaction = viewModel.filteredTransactions[indexPath.row]
        cell.configure(with: transaction)
        cell.tag = indexPath.row
        cell.delegate = viewModel.delegate
        
        if let contact = transaction.contact {
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
            cell.contactImageView.image = UIImage.init(named: "QRIcon")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTransactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83
    }

}
