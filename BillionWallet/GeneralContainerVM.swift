//
//  GeneralContainerVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol GeneralContainerVMDelegate: class {

}

class GeneralContainerVM {

    weak var delegate: GeneralContainerVMDelegate?
    
    private let router: MainRouter
    private let viewControllers: [UIViewController]

    init(router: MainRouter) {
        self.router = router
        let buyViewController = router.getBuyView()
        let generalViewController = router.getGeneralView()
        let shopViewController = router.getShopView()
        self.viewControllers = [buyViewController, generalViewController, shopViewController]
    }
    
    var viewControllersCount: Int {
        return viewControllers.count
    }
    
    var lastViewController: UIViewController? {
        return viewControllers.last
    }
    
    var firstViewController: UIViewController? {
        return viewControllers.first
    }
    
    func getViewController(at index: Int) -> UIViewController {
        return viewControllers[index]
    }
    
    func index(of viewController: UIViewController) -> Int? {
        return viewControllers.index(of: viewController)
    }

}
