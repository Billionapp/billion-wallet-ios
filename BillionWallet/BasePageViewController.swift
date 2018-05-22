//
//  BasePageViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class BasePageViewController<T>: UIPageViewController {
    
    private(set) var viewModel: T
    
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        configure(viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel:T) {}

}
