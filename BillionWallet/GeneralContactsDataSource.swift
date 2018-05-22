//
//  GeneralContactsDataSource.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol GeneralContactsDataSourceDelegate: class {
    func didSelect(at index: Int)
}

class GeneralContactsDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    weak var viewModel: GeneralVM!
    
    weak var delegate: GeneralContactsDataSourceDelegate?
    
    init(viewModel: GeneralVM) {
        self.viewModel = viewModel
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        let contact = viewModel.contacts[indexPath.row]
        cell.nameLabel.text = contact.givenName
        cell.avatarImageView.image = contact.avatarImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contacts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(at: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
}

// MARK: - DZNEmptyDataSetSource

extension GeneralContactsDataSource: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "EmptyContacts")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .semibold), NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        return NSAttributedString(string: Strings.Contacts.noContacts, attributes: attributes)
    }
    
}

