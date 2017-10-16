//
//  ContactsVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol ContactsVMDelegate: class {
    func searchStringDidChange(searchString: String)
    func filteredDidChanged(filteredArray: [ContactProtocol])
    func searchDidBegin(buttonWidth: CGFloat)
    func didSelectContact(_ contact: ContactProtocol)
    func didPickContact(_ contact: ContactProtocol)
}

protocol ContactsOutputDelegate: class {
    func didSelectContact(_ contact: ContactProtocol)
}

class ContactsVM: NSObject {
    
    enum Mode {
        case `default`
        case pick
    }
    
    fileprivate let mode: Mode
    fileprivate let contactsProvider: ContactsProvider?
    weak var delegate: ContactsVMDelegate?
    weak var output: ContactsOutputDelegate?
    
    var originalContactsArray: [ContactProtocol] = []
    var filteredContactsArray: [ContactProtocol] = [] {
        didSet {
            delegate?.filteredDidChanged(filteredArray: filteredContactsArray)
        }
    }
    
    var searchString: String = "" {
        didSet {
            delegate?.searchStringDidChange(searchString: searchString)
            if searchString == "" {
                filteredContactsArray = originalContactsArray
            } else {
                filteredContactsArray = originalContactsArray.filter({($0.displayName.lowercased().contains(searchString.lowercased()))})
            }
        }
    }

    init(contactsProvider: ContactsProvider, output: ContactsOutputDelegate?, mode: Mode) {
        self.contactsProvider = contactsProvider
        self.output = output
        self.mode = mode
    }
    
    func initData() {
        if let contactsAll = contactsProvider?.allContacts(isArchived: false) {
            originalContactsArray = contactsAll
            filteredContactsArray = originalContactsArray
        }
    }

}

extension ContactsVM: UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredContactsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactsCell", for: indexPath) as! ContactsCell
        
        let contact = filteredContactsArray[indexPath.row]
        cell.name?.text = contact.displayName
        cell.picture?.image = contact.avatarImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedContact = filteredContactsArray[indexPath.row]
        
        switch mode {
        case .default:
            delegate?.didSelectContact(selectedContact)
        case .pick:
            output?.didSelectContact(selectedContact)
            delegate?.didPickContact(selectedContact)
        }
    }
    
    // MARK: Text field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 0 { //adding character
            self.searchString = "\(textField.text ?? "")\(string)"
            
            return true
        } else { //erase last character
            if range.location == 0  { //all characters was erased
                self.searchString = ""
            } else {
                let text = textField.text ?? ""
                self.searchString = String(text.characters.dropLast())
            }
            
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let titleCancelButton = NSLocalizedString("Cancel", comment: "")
        let requiredSize = (titleCancelButton as NSString).boundingRect(with: CGSize(width:CGFloat.greatestFiniteMagnitude, height:30), options: .usesDeviceMetrics, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], context: nil).size
        delegate?.searchDidBegin(buttonWidth: requiredSize.width+10)
    }

}
