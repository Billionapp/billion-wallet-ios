//
//  ChooseSenderDataSource.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol ChooseSenderDataSourceDelegate: class {
    func didSelect(at index: Int)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class ChooseSenderDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    weak var viewModel: ChooseSenderVM!
    
    weak var delegate: ChooseSenderDataSourceDelegate?
    
    init(viewModel: ChooseSenderVM) {
        self.viewModel = viewModel
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        let contact = viewModel.contacts[indexPath.row]
        cell.nameLabel.text = contact.givenName
        cell.avatarImageView.image = contact.avatarImage
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if viewModel.contacts.count < 3 {
            let cellHeight: CGFloat = Layout.model.contactCellHeight
            let headerHeight: CGFloat = tableView.tableHeaderView?.frame.height ?? 0
            let footerHeight: CGFloat = tableView.tableFooterView?.frame.height ?? 0
            return tableView.frame.height - headerHeight - CGFloat(viewModel.contacts.count) * cellHeight - footerHeight
        }
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
    
}

// MARK: - DZNEmptyDataSetSource

extension ChooseSenderDataSource: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "EmptyContacts")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .semibold), NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        return NSAttributedString(string: "You have no contacts", attributes: attributes)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        if let tableView = scrollView as? UITableView {
            let headerHeight: CGFloat = tableView.tableHeaderView?.frame.height ?? 0
            let footerHeight: CGFloat = tableView.tableFooterView?.frame.height ?? 0
            let offset = tableView.frame.height - headerHeight + footerHeight
            return offset / 2
        }
        return 0
    }
    
}
