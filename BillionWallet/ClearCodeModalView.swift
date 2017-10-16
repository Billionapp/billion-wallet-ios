//
//  ClearCodeModalView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class ClearCodeModalView: UIView {

    @IBOutlet private weak var codeImage: UIImageView?
    @IBOutlet private weak var addressLabel: UILabel?
    
    private weak var viewModel: SendVM?

    init(address: String, image: UIImage, viewModel: SendVM) {
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        addBlur()
        codeImage?.image = image
        addressLabel?.text = address
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func clearAction() {
        viewModel?.address = ""
        close()
    }
    
    @IBAction func closeAction() {
        close()
    }
    
    func close() {
        self.removeFromSuperview()
    }
}
