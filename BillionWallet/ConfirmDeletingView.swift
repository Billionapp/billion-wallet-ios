//
//  ConfirmDeletingView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol ConfirmDeletingViewDelegate: class {
    func contactDeleted()
}

class ConfirmDeletingView: UIView {
    
    typealias LocalizedString = Strings.Modal
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var deleteButton: GradientButton!
    @IBOutlet weak var cancelButton: GradientButton!
    
    weak var delegate: ConfirmDeletingViewDelegate?
    
    init(backView: UIImage) {
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        let imageView = UIImageView(image: backView)
        view.insertSubview(imageView, at: 0)
        configureButtonsTittle()
    }
    
    private func configureButtonsTittle() {
        deleteButton.setTitle(LocalizedString.deleteButton, for: .normal)
        cancelButton.setTitle(LocalizedString.cancelButton, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func deleteContact(_ sender: GradientButton) {
        delegate?.contactDeleted()
        removeFromSuperview()
    }
    
    @IBAction func cancel(_ sender: GradientButton) {
        self.removeFromSuperview()
    }
    
    
}
