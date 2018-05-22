//
//  SendInputAddressRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

final class SendInputAddressRouter {
    // MARK: - Private
    private let mainRouter: MainRouter
    private let application: Application
    private let back: UIImage?
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter, application: Application, back: UIImage?) {
        self.mainRouter = mainRouter
        self.application = application
        self.back = back
    }
    
    // MARK: - Start routing
    func run(paymentRequest: PaymentRequest, userPaymentRequest: UserPaymentRequest?, failureTransaction: FailureTx?) {
        let maxSendAmountBuilder = AddressMaxAmountBuilder(walletProvider: application.walletProvider,
                                                           feeProvider: application.feeProvider,
                                                           sizeApproximizer: StandardTxSizeApproximizer())
        let viewModel = SendInputAddressVM(maxSendAmountBuilder: maxSendAmountBuilder,
                                           paymentRequest: paymentRequest,
                                           ratesProvider: application.ratesProvider,
                                           defaultsProvider: application.defaults,
                                           tapticService: application.tapticService,
                                           walletProvider: application.walletProvider)
        viewModel.userPaymentRequest = userPaymentRequest
        viewModel.failureTransaction = failureTransaction
        let sendInputViewController = SendInputAddressViewController(viewModel: viewModel)
        sendInputViewController.mainRouter = mainRouter
        sendInputViewController.backImage = back
        
        let balanceView = createBalanceView()
        sendInputViewController.addBalanceView(balanceView)
        mainRouter.navigationController.push(viewController: sendInputViewController)
    }
    
    private func createBalanceView() -> BillionBalanceView {
        let balanceView = BillionBalanceView(frame: CGRect.zero)
        let balanceVM = SendInputBalanceVM(defaults: application.defaults,
                                           walletProvider: application.walletProvider,
                                           lockProvider: application.lockProvider,
                                           fiatConverter: application.fiatConverter,
                                           localAuthProvider: TouchIDManager())
        balanceView.setVM(balanceVM)
        return balanceView
    }
}
