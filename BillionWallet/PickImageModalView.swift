//
//  ClearCodeModalView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class PickImageModalView: UIView {
    
    private weak var viewModel: ScanVM?
    private weak var scanController: ScanViewController?
    @IBOutlet weak var photoCollection: UICollectionView!
    

    init(viewModel: ScanVM, controller: ScanViewController) {
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        self.viewModel = viewModel
        self.scanController = controller
        setupCollection()
        viewModel.pickDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollection() {
        let nib = UINib.init(nibName: "PickImageCell".nibName(), bundle: nil)
        photoCollection.register(nib, forCellWithReuseIdentifier: "PickImageCell")
        photoCollection.dataSource = viewModel
        photoCollection.delegate = viewModel
    }
    
    @IBAction func gotoGallery() {
        scanController?.pickFromGalleryActionWithoutEditing()
        close()
    }
    
    @IBAction func closeAction() {
        close()
    }
    
    func close() {
        self.removeFromSuperview()
    }
}

extension PickImageModalView: PickVMDelegate {
    func cropDidEnd() {
        DispatchQueue.main.async {
            self.photoCollection.reloadData()
        }
    }
}
