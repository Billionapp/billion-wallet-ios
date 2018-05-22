//
//  Colors.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

struct Color {
    static let baseButton = UIColor(red: 130/255, green: 144/255, blue: 183/255, alpha: 1.0)
    static let buttonTop = baseButton.withAlphaComponent(0.4)
    static let buttonBottom = baseButton.withAlphaComponent(0.2)
    static let buttonTopSelected = baseButton.withAlphaComponent(0.6)
    static let buttonBottomSelected = baseButton.withAlphaComponent(0.4)
    static let defaultGray = UIColor(red: 57/255, green: 63/255, blue: 79/255, alpha: 1)

    
    struct ProfileCardGradient {
        static let startColor = defaultGray.withAlphaComponent(0.7)
        static let endColor = defaultGray.withAlphaComponent(0.6)
    }
    
    struct FeeSlider {
        static let minimumSliderColor = UIColor(red: 172/255, green: 178/255, blue: 191/255, alpha: 0.85)
        static let maximumSliderColor = UIColor(red: 116/255, green: 123/255, blue: 139/255, alpha: 0.5)
    }
    
    struct Onboard {
        static let labelColor = UIColor.white
    }
}
