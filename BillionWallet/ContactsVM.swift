//
//  ContactsVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

let contactsChangedAfterSaveNotification: Notification.Name = Notification.Name(rawValue: "contactsChangedAfterSaveNotification")

protocol ContactsVMDelegate: class {
    func searchStringDidChange(searchString: String)
    func filteredDidChanged(filteredArray: [ContactProtocol])
    func searchDidBegin(buttonWidth: CGFloat)
    func didSelectContact(_ contact: ContactProtocol)
    func didPickContact(_ contact: ContactProtocol)
    func contactsCountEqualZero(_ flag: Bool)
}

protocol ContactsOutputDelegate: class {
    func didSelectContact(_ contact: ContactProtocol)
}

// @deadpool
// TODO: incapsulation
class ContactsVM: NSObject {
    
    typealias LocalizedStrings = Strings.Contacts
    
    enum Mode {
        case `default`
        case pick
    }
    
    private let mode: Mode
    private weak var contactsProvider: ContactsProvider!
    private weak var scannerProvider: ScannerDataProvider!
    private weak var tapticService: TapticService!
    private var deleteIndexPath: IndexPath?
    
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

    init(contactsProvider: ContactsProvider,
         output: ContactsOutputDelegate?,
         mode: Mode,
         scannerProvider: ScannerDataProvider,
         tapticService: TapticService) {
        
            self.contactsProvider = contactsProvider
            self.output = output
            self.mode = mode
            self.scannerProvider = scannerProvider
            self.tapticService = tapticService
    }
    
    deinit {
        scannerProvider?.scannedString = ""
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(initData), name: contactsChangedAfterSaveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(initData), name: .iCloudContactsDidFinishSyncronizationNotitfication, object: nil)
    }
    
    @objc func initData() {
        if let contactsAll = contactsProvider?.allContacts(isArchived: false) {
            originalContactsArray = contactsAll
            filteredContactsArray = originalContactsArray
        }
    }
}

extension ContactsVM: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let isZero = filteredContactsArray.count == 0 ? true : false
        delegate?.contactsCountEqualZero(isZero)
        return filteredContactsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactsCell", for: indexPath) as! ContactsCell
        let contact = filteredContactsArray[indexPath.row]
        cell.name.text = contact.givenName
        cell.picture.image = contact.avatarImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedContact = filteredContactsArray[indexPath.row]
        switch mode {
        case .default:
            delegate?.didSelectContact(selectedContact)
        case .pick:
            delegate?.didPickContact(selectedContact)
            output?.didSelectContact(selectedContact)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView.contentOffset.y != collectionView.contentSize.height - collectionView.frame.size.height + collectionView.contentInset.bottom else { return }
        tapticService.selectionTaptic(capability:
            collectionView.traitCollection.forceTouchCapability == .available)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView.contentOffset.y != collectionView.contentSize.height - collectionView.frame.size.height + collectionView.contentInset.bottom else { return }
        tapticService.selectionTaptic(capability:
            collectionView.traitCollection.forceTouchCapability == .available)
    }
}

// MARK: - DZNEmptyDataSetSource

extension ContactsVM: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "EmptyContacts")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .semibold), NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        return NSAttributedString(string: LocalizedStrings.noContacts, attributes: attributes)
    }
}
