//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

import Foundation

class ___VARIABLE_moduleName___Router: Router {

    private let mainRouter: MainRouter

    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }

    func run() {
        let viewModel = ___VARIABLE_moduleName___VM()
        let viewController = ___VARIABLE_moduleName___ViewController(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }
}
