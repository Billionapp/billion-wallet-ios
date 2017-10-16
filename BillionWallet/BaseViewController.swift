//
//  BaseViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class BaseViewController<T>: UIViewController, UINavigationControllerDelegate  {
    
    private(set) var viewModel:T
    
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: type(of: self)).nibName(), bundle: nil)
        configure(viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel:T) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.disableBackSwipe()
        navigationController?.addSwipeDown()
        navigationController?.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard operation == .pop else {return nil}
        return Animator()
    }
}

extension String {
    func nibName() -> String {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        if width == 375 {
            return "\(self)7+"
        } else if width == 414 {
            return "\(self)7+"
        } else if height == 568 {
            return "\(self)7+"
        } else {
            return "\(self)7+"
        }
    }
}

extension String {
    func nibNameForCell() -> String {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        if width == 375 {
            return "\(self)7+"
        } else if width == 414 {
            return "\(self)7"
        } else if height == 568 {
            return "\(self)5"
        } else {
            return "\(self)5"
        }
    }
}
