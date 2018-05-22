//
//  Strings+About.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 3/19/18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum About {
        static let titleAboutPC = NSLocalizedString("About.titleAboutPC",
                                                    tableName: "About",
                                                    value: "Payment code",
                                                    comment: "Payment code about title")
        
        static let titleAirConnectivity = NSLocalizedString("About.titleAirConnectivity",
                                                            tableName: "About",
                                                            value: "Air Connectivity",
                                                            comment: "Air Connectivity about title")
        
        static let titleReceive = NSLocalizedString("About.titleReceive",
                                                    tableName: "About",
                                                    value: "Receive & Send",
                                                    comment: "Receive & Send about title")
        
        static let titleFee = NSLocalizedString("About.titleFee",
                                                tableName: "About",
                                                value: "Modify custom fee",
                                                comment: "Fee about title")
        
        static let titleSatoshi = NSLocalizedString("About.titleSatoshi",
                                                    tableName: "About",
                                                    value: "Satoshi",
                                                    comment: "Satoshi about title")
        
        static let titleSpv = NSLocalizedString("About.titleSpv",
                                                tableName: "About",
                                                value: "SPV architecture",
                                                comment: "Spv architecture about title")
        
        static let forgetLabelAboutPC = NSLocalizedString("About.forgetLabelAboutPC",
                                                          tableName: "About",
                                                          value: "Forget about mobile or email verification. Set up a recovery phrase, tune in your pseudonymous BillionCard based on a stealth BIP47 Reusable Payment Code. It provides true privacy for your identity and transactions.",
                                                          comment: "Payment code about label text")
        
        static let withReusableLabel = NSLocalizedString("About.withReusableLabelAbout",
                                                         tableName: "About",
                                                         value: "With Reusable Payment Codes you can privately add contacts — make it in almost no taps with Air Connectivity.",
                                                         comment: "Air connectivity about label text")
        
        static let enjoyLabel = NSLocalizedString("About.enjoyLabelAbout",
                                                  tableName: "About",
                                                  value: "Enjoy hassle-free financial interaction with your contacts — make direct requests to receive funds and send them in a few taps",
                                                  comment: "Enjoy hassle-free label text")
        
        static let findingLabel = NSLocalizedString("About.findingLabelAbout",
                                                    tableName: "About",
                                                    value: "Finding a nearby contact ...",
                                                    comment: "Air connectivity finding label text")
        
        static let toInstantlyLabel = NSLocalizedString("About.toInstantlyLabelAbout",
                                                        tableName: "About",
                                                        value: "To instantly add both users should enable this mode",
                                                        comment: "Air connectivity to instantly label text")
        
        static let fromLabel = NSLocalizedString("About.fromLabel",
                                                 tableName: "About",
                                                 value: "From?",
                                                 comment: "From label text")
        
        static let saveLabel = NSLocalizedString("About.saveLabel",
                                                 tableName: "About",
                                                 value: "Save money on fees! Billion allows you to choose Bitcoin network fee — make a transaction confirmed as fast as possible, or put it until tomorrow and make it cheaper.",
                                                 comment: "From label text")
        
        static let satLabel = NSLocalizedString("About.satoshiLabel",
                                                tableName: "About",
                                                value: "Do Bitcoin the Satoshi Way — denomination inside Billion is satoshi ㋛, no need to count zeros anymore!",
                                                comment: "Satoshi label text")
        
        static let spvLabel = NSLocalizedString("About.spvLabel",
                                                tableName: "About",
                                                value: "All this robust SPV architecture. it provides a direct connection to the Bitcoin network — forget about ‘server maintenance’.",
                                                comment: "Spv architeecture label text")
        
        static let nextButtonTitle = NSLocalizedString("About.nextButtonTitle",
                                                       tableName: "About",
                                                       value: "Next",
                                                       comment: "Next button title")
        
        static let feeTimeLabel = NSLocalizedString("About.feeTimeLabel",
                                                    tableName: "About",
                                                    value: "Confirm time",
                                                    comment: "Fee confirm time text")
        
        static let feeTotalLabel = NSLocalizedString("About.feeTotalLabel",
                                                     tableName: "About",
                                                     value: "Total fee",
                                                     comment: "Fee total text")
        
        static let spvTopLabel = NSLocalizedString("About.spvTopLabel",
                                                   tableName: "About",
                                                   value: "Syncing with blockchain",
                                                   comment: "Spv syncing text")
        
        static let spvBottomLabel = NSLocalizedString("About.spvBottomLabel",
                                                      tableName: "About",
                                                      value: "2017 June 10 14:57",
                                                      comment: "Spv time text")
    }
}
