//
//  BaseViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit


class BaseViewController<T>: UIViewController, UINavigationControllerDelegate  {
    
    private(set) var viewModel: T
    
    var backImage: UIImage?
    
    init(viewModel: T) {
        self.viewModel = viewModel
        let className = "\(type(of: self))"
        super.init(nibName: className.xibName(), bundle: nil)
        configure(viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: T) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.disableBackSwipe()
        navigationController?.addSwipeDown()
        navigationController?.delegate = self
        setupBackImageIfNeeded()
    }
    
    fileprivate func setupBackImageIfNeeded() {
        if let backImage = backImage {
            let imageView = UIImageView(image: backImage)
            view.insertSubview(imageView, at: 0)
        }
    }
    
    func removeSwipeDownGesture() {
        if let gestures = self.view.gestureRecognizers {
            for gesture in gestures {
                if let swipeDown = gesture as? UISwipeGestureRecognizer {
                    self.view.removeGestureRecognizer(swipeDown)
                }
            }
        }
    }
    
    func addGradientOnTop() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40)
        gradient.zPosition = 1
        gradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        view.layer.addSublayer(gradient)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard operation == .pop else {return nil}
        return Animator()
    }
}

fileprivate extension String {
    func xibName() -> String {
        let name = nibName()
        if let _ = Bundle.main.path(forResource: name, ofType: "nib") {
            return name
        } else {
            return "\(self)7+"
        }
    }
}

