//
//  SplashView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class SplashView: UIView {
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        startTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
    }
    
    func startTimer()  {
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            self.removeFromSuperview()
        }
    }
}
