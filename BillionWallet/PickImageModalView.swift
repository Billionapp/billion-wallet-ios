//
//  ClearCodeModalView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class PickImageModalView: UIView {
    
    typealias Localized = Strings.Scan
    
    private weak var viewModel: ScanVM?
    private weak var scanController: ScanViewController?
    @IBOutlet weak var galeryButton: UIButton! {
        didSet {
            galeryButton.setTitle(Localized.galeryButton, for: .normal)
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle(Localized.cancelButton, for: .normal)
        }
    }
    @IBOutlet weak var photoCollection: UICollectionView!
    private var titledView: TitledView!
    
    init(viewModel: ScanVM, controller: ScanViewController) {
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        self.viewModel = viewModel
        self.scanController = controller
        setupCollection()
        viewModel.pickDelegate = self
        setupTitledView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = Localized.extractQRTitle
        titledView.subtitle = Localized.selectImageWithQR
        titledView.closePressed = {
            self.close()
        }
        addSubview(titledView)
    }
    
    func setupCollection() {
        let nib = UINib.init(nibName: "PickImageCell".xibCellName(), bundle: nil)
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
