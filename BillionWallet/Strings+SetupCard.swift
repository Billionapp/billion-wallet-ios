//
//  Strings+SetupCard.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum SetupCard {

        static let header = NSLocalizedString("SetupCard.BillionCard",
                                              tableName: "SetupCard", value: "BillionCard",
                                              comment: "Setup card header")
        
        static let selectionSubtitle = NSLocalizedString("SetupCard.ChoosePhoto",
                                                         tableName: "SetupCard",
                                                         value: "Choose photo",
                                                         comment: "Image selection subtitle")
        
        static let profileSubtitle = NSLocalizedString("SetupCard.AddAName",
                                                       tableName: "SetupCard",
                                                       value: "Add a name for sharing your profile",
                                                       comment: "Card subtitle")
        
        static let pcTitle = NSLocalizedString("SetupCard.PcTitle",
                                               tableName: "SetupCard",
                                               value: "Payment code",
                                               comment: "Payment code title in profile")
        
        static let nameLabel = NSLocalizedString("SetupCard.NameLabel",
                                                 tableName: "SetupCard",
                                                 value: "Name:",
                                                 comment: "Name title in profile")
        
        static let placeholder = NSLocalizedString("SetupCard.NamePlaceholder",
                                                   tableName: "SetupCard",
                                                   value: "Enter your alias or name",
                                                   comment: "Name text field placeholder")
        
        static let gotoGaleryButton = NSLocalizedString("SetupCard.GoToGallery",
                                                        tableName: "SetupCard",
                                                        value: "Go to «Gallery»",
                                                        comment: "Setup card go to Gallery button title")
        
        static let cameraOpenButton = NSLocalizedString("SetupCard.OpenCamera",
                                                        tableName: "SetupCard",
                                                        value: "Camera",
                                                        comment: "Setup card open camera button title")
        
        static let startButton = NSLocalizedString("SetupCard.Start",
                                                   tableName: "SetupCard",
                                                   value: "Start",
                                                   comment: "Setup card start button")
    }
}
