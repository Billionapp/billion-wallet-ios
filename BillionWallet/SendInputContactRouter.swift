//
//  SendInputContactRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

final class SendInputContactRouter {
    // MARK: - Private
    private let mainRouter: MainRouter
    private let app: Application
    private let back: UIImage?
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter, application: Application, back: UIImage?) {
        self.mainRouter = mainRouter
        self.app = application
        self.back = back
    }
    
    // MARK: - Start routing
    func run(contact: PaymentCodeContactProtocol, failureTransaction: FailureTx?) {
        let maxSendAmountBuilder = PCMaxAmountBuilder(walletProvider: app.walletProvider,
                                                      contact: contact,
                                                      feeProvider: app.feeProvider,
                                                      notificationSizeApproximizer: NotificationV1TxSizeApproximizer(),
                                                      regularSizeApproximizer: StandardTxSizeApproximizer())
        let viewModel = SendInputContactVM(maxSendAmountBuilder: maxSendAmountBuilder,
                                           contact: contact,
                                           ratesProvider: app.ratesProvider,
                                           defaultsProvider: app.defaults,
                                           lockProvider: app.lockProvider,
                                           tapticService: app.tapticService,
                                           walletProvider: app.walletProvider)
        viewModel.failureTransaction = failureTransaction
        let sendInputViewController = SendInputContactViewController(viewModel: viewModel)
        sendInputViewController.mainRouter = mainRouter
        sendInputViewController.backImage = back
        
        let balanceView = createBalanceView()
        sendInputViewController.addBalanceView(balanceView)
        mainRouter.navigationController.push(viewController: sendInputViewController)
    }
    
    func run(displayer: UserPaymentRequestDisplayer, contact: PaymentCodeContactProtocol) {
        let maxSendAmountBuilder = PCMaxAmountBuilder(walletProvider: app.walletProvider,
                                                      contact: contact,
                                                      feeProvider: app.feeProvider,
                                                      notificationSizeApproximizer: NotificationV1TxSizeApproximizer(),
                                                      regularSizeApproximizer: StandardTxSizeApproximizer())
        let viewModel = SendInputContactVM(maxSendAmountBuilder: maxSendAmountBuilder,
                                           contact: contact,
                                           ratesProvider: app.ratesProvider,
                                           defaultsProvider: app.defaults,
                                           lockProvider: app.lockProvider,
                                           tapticService: app.tapticService,
                                           walletProvider: app.walletProvider)
        viewModel.displayer = displayer
        let sendInputViewController = SendInputContactViewController(viewModel: viewModel)
        sendInputViewController.mainRouter = mainRouter
        sendInputViewController.backImage = back
        
        let balanceView = createBalanceView()
        sendInputViewController.addBalanceView(balanceView)
        mainRouter.navigationController.push(viewController: sendInputViewController)
    }
    
    private func createBalanceView() -> BillionBalanceView {
        let balanceView = BillionBalanceView(frame: CGRect.zero)
        let balanceVM = SendInputBalanceVM(defaults: app.defaults,
                                           walletProvider: app.walletProvider,
                                           lockProvider: app.lockProvider,
                                           fiatConverter: app.fiatConverter,
                                           localAuthProvider: TouchIDManager())
        balanceView.setVM(balanceVM)
        return balanceView
    }
}
