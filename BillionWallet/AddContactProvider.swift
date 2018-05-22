//
//  AddContactProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import CoreBluetooth
import MultipeerConnectivity

protocol AddContactProviderDelegate: class {
    func addContactProviderFailed(with error: Error)
    func addContactProviderReceive(_ contact: ContactProtocol)
    func addContactProviderReadyForSearch()
}

enum AddContactProviderError: LocalizedError {
    case couldntExtractContact
    case disconnected
    
    var errorDescription: String? {
        switch self {
        case .couldntExtractContact:
            return "Could not extract contact"
        case .disconnected:
            return "Disconnected"
        }
    }
}

class AddContactProvider: NSObject {
    
    weak var delegate: AddContactProviderDelegate?
    weak var icloud: ICloud!
    
    #if BITCOIN_TESTNET
    private let serviceType = "billion-test"
    #else
    private let serviceType = "billion-service"
    #endif
    private var peerId: MCPeerID!
    private var advertiserService: MCNearbyServiceAdvertiser!
    private var browserService: MCNearbyServiceBrowser!
    private var session: MCSession!
    private var peripheralManager: CBPeripheralManager!
    private var accountProvider: AccountManager!
    
    init(icloud: ICloud, accountProvider: AccountManager) {
        super.init()
        self.accountProvider = accountProvider
        self.icloud = icloud
    }
    
    func checkBletooth() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func start() {
        
        let paymentCode = accountProvider.getSelfPCString()
        let displayName = "Billionaire.." + paymentCode.suffix(10)
        peerId = MCPeerID(displayName: displayName)
        advertiserService = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        browserService = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        
        advertiserService.delegate = self
        advertiserService.startAdvertisingPeer()
        
        browserService.delegate = self
        browserService.startBrowsingForPeers()
        
        session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }
    
    func sendSelfContact(peerID: MCPeerID) {
    
        let paymentCode = accountProvider.getSelfPCString()
        var userData = UserData(paymentCode: paymentCode)
        
        if let icloudUserData = icloud.restoreObjectsFromBackup(LocalUserData.self).first {
            userData.name = icloudUserData.name
            userData.avatarData = icloudUserData.imageData
        }
        
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: userData.json)
        
        guard session.connectedPeers.contains(peerID) else {
            Logger.debug("connectedPeers.contains !!!")
            return
        }
        
        do {
            try session.send(dataToSend, toPeers: [peerID], with: .reliable)
        } catch {
            delegate?.addContactProviderFailed(with: error)
        }
    }
    
    func extractContact(from data: Data) {
        guard
            let json = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any],
            let userData = UserData(json: JSON(json)) else {
                delegate?.addContactProviderFailed(with: AddContactProviderError.couldntExtractContact)
                return
        }
        
        var contact = FriendContact.create(unique: userData.pc)
        contact.avatarData = userData.avatarData
        
        if let name = userData.name {
            contact.displayName = name
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.addContactProviderReceive(contact)
        }
    }
    
    func stop() {
        advertiserService?.stopAdvertisingPeer()
        browserService?.stopBrowsingForPeers()
        peripheralManager.stopAdvertising()
    }
    
}

// MARK: - CBPeripheralManagerDelegate

extension AddContactProvider: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
//        if peripheral.state != .unauthorized &&
//            peripheral.state != .unsupported &&
//            peripheral.state != .unknown &&
//            peripheral.state != .poweredOff {
            delegate?.addContactProviderReadyForSearch()
            peripheral.stopAdvertising()
//        }
    }
    
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension AddContactProvider: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        Logger.debug(error.localizedDescription)
        delegate?.addContactProviderFailed(with: error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        Logger.debug("accepting invite from: \(peerID.displayName)")
        invitationHandler(true, session)
    }
    
}

// MARK: - MCNearbyServiceBrowserDelegate

extension AddContactProvider: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Logger.debug(error.localizedDescription)
        delegate?.addContactProviderFailed(with: error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        Logger.debug("invitePeer: \(peerID.displayName)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
}

// MARK: - MCSessionDelegate

extension AddContactProvider: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        Logger.debug("didReceiveData from: \(peerID)")
        extractContact(from: data)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:
            Logger.debug("Connecting to \(peerID.displayName)")
        case .connected:
            Logger.debug("Connected to \(peerID.displayName)")
            sendSelfContact(peerID: peerID)
        case .notConnected:
            Logger.debug("Dicconected from \(peerID.displayName)")
            delegate?.addContactProviderFailed(with: AddContactProviderError.disconnected)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
}
