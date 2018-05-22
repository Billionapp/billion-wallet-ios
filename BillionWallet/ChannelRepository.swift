//
//  ChannelRepository.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 19.03.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

typealias ContactChannel = Channel<ContactsProvider.ContactMessage>

class ChannelRepository {
    let contactsChannel: ContactChannel = ContactChannel()
}
