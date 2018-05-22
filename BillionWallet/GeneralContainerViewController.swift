//
//  GeneralContainerViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GeneralContainerViewController: BasePageViewController<GeneralContainerVM>, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private let startIndex = 1
    private let pageControl = UIPageControl()

    override func configure(viewModel: GeneralContainerVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupPageControl()
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - Private methods
    
    private func setupPageViewController() {
        dataSource = self
        delegate = self
        let initialViewController = viewModel.getViewController(at: startIndex)
        setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        pageControl.backgroundColor = UIColor.clear
        pageControl.numberOfPages = viewModel.viewControllersCount
        pageControl.currentPage = startIndex
        pageControl.isUserInteractionEnabled = false
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewModel.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        let next = viewModel.getViewController(at: previousIndex)
        return next
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        
        guard let viewControllerIndex = viewModel.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < viewModel.viewControllersCount else { return nil }

        
        let next = viewModel.getViewController(at: nextIndex)
        return next
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let vc = pageViewController.viewControllers?.first,
            let index = viewModel.index(of: vc),
            let prevVC = previousViewControllers.first,
            let prevIndex = viewModel.index(of: prevVC) else {
                return
        }
        
        if let general = viewModel.getViewController(at: 1) as? GeneralViewController {
            if index == 1 {
                general.setupConveyorView()
            } else if prevIndex == 1 {
                general.unsetConveyorView()
            }
        }
        
        pageControl.currentPage = index
    }

}

extension GeneralContainerViewController: GeneralContainerVMDelegate {

}
