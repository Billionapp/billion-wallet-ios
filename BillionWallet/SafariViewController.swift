//
//  SafariViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import SafariServices

class SafariViewContoller: SFSafariViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
