//
//  ChooseFeeAddressRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

final class ChooseFeeAddressRouter {
    // MARK: - Private
    private let mainRouter: MainRouter
    private let application: Application
    private let back: UIImage?
    private let conveyor: TouchConveyorView?
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter,
         application: Application,
         back: UIImage?,
         conveyor: TouchConveyorView?) {
        
        self.mainRouter = mainRouter
        self.application = application
        self.back = back
        self.conveyor = conveyor
    }
    
    // MARK: - Start routing
    func run(address: String, amount: UInt64, userNote: String?) {
        let txGenerator = DefaultTxGeneratorFactory(wallet: application.walletProvider,
                                                    accountManager: application.accountProvider).generatorForAddress(address)
        let txSigner = StandardTxSigner(walletProvider: application.walletProvider)
        let txPublisher = DefaultTxPublisherFactory(peerMan: application.walletProvider).publisher()
        
        var failurePostPublishers = [TxPostPublish]()
        
        let failurePostPublisher = TxPostPublishCreateFailureTx(failureTxProvider: application.failureTxProvider, walletProvider: application.walletProvider, contact: nil)
        failurePostPublishers.append(failurePostPublisher)
        
        let txPostPublisher = TxPostPublisher(successPostPublishTasks: [], failurePostPublishTasks: failurePostPublishers)
        
        let sendTransactionProvider = SendTransactionProvider(txGenerator: txGenerator, txSigner: txSigner, txPublisher: txPublisher, txPostPublisher: txPostPublisher, feeProvider: application.feeProvider)
        
        let viewModel = ChooseFeeVM(sendTransactionProvider: sendTransactionProvider,
                                    defaultsProvider: application.defaults,
                                    ratesProvider: application.ratesProvider,
                                    noteProvider: application.notesProvider,
                                    confirmTimeFormatter: application.confirmMinuterFormatter,
                                    tapticService: application.tapticService,
                                    contactsProvider: application.contactsProvider)
        viewModel.amount = amount
        viewModel.userNote = userNote
        let sendInputViewController = ChooseFeeViewController(viewModel: viewModel)
        sendInputViewController.mainRouter = mainRouter
        sendInputViewController.backImage = back
        sendInputViewController.conveyorView = conveyor
        mainRouter.navigationController.push(viewController: sendInputViewController)
    }
    
    func run(userPaymentRequest: UserPaymentRequest, userNote: String?) {
        let txGenerator = DefaultTxGeneratorFactory(wallet: application.walletProvider,
                                                    accountManager: application.accountProvider).generatorForAddress(userPaymentRequest.address)
        let txSigner = StandardTxSigner(walletProvider: application.walletProvider)
        let txPublisher = DefaultTxPublisherFactory(peerMan: application.walletProvider).publisher()
        
        var successPostPublishers = [TxPostPublish]()
        var failurePostPublishers = [TxPostPublish]()
        
        let successPostPublish = TxPostAcceptPaymentRequest(paymentRequest: userPaymentRequest, paymentRequestProvider: application.userPaymentRequestProvider)
        successPostPublishers.append(successPostPublish)
        
        let failurePostPublish = TxPostPublishFailurePaymentRequest(userPaymentRequest: userPaymentRequest, userPaymentRequestProvider: application.userPaymentRequestProvider)
        failurePostPublishers.append(failurePostPublish)
        
        let txPostPublisher = TxPostPublisher(successPostPublishTasks: successPostPublishers, failurePostPublishTasks: failurePostPublishers)
        
        let sendTransactionProvider = SendTransactionProvider(txGenerator: txGenerator,
                                                              txSigner: txSigner,
                                                              txPublisher: txPublisher,
                                                              txPostPublisher: txPostPublisher,
                                                              feeProvider: application.feeProvider)
        
        let viewModel = ChooseFeeVM(sendTransactionProvider: sendTransactionProvider,
                                    defaultsProvider: application.defaults,
                                    ratesProvider: application.ratesProvider,
                                    noteProvider: application.notesProvider,
                                    confirmTimeFormatter: application.confirmMinuterFormatter,
                                    tapticService: application.tapticService,
                                    contactsProvider: application.contactsProvider)
        viewModel.amount = UInt64(userPaymentRequest.amount)
        viewModel.userNote = userNote
        let sendInputViewController = ChooseFeeViewController(viewModel: viewModel)
        sendInputViewController.mainRouter = mainRouter
        sendInputViewController.backImage = back
        sendInputViewController.conveyorView = conveyor
        mainRouter.navigationController.push(viewController: sendInputViewController)
    }
    
    func run(failureTx: FailureTx, userNote: String?) {
        let txGenerator = DefaultTxGeneratorFactory(wallet: application.walletProvider,
                                                    accountManager: application.accountProvider).generatorForAddress(failureTx.address)
        let txSigner = StandardTxSigner(walletProvider: application.walletProvider)
        let txPublisher = DefaultTxPublisherFactory(peerMan: application.walletProvider).publisher()
        
        var successPostPublishers = [TxPostPublish]()
        
        let postPublish = TxPostDeleteFailureTransaction(failureTransaction: failureTx, failureTxProvider: application.failureTxProvider)
        successPostPublishers.append(postPublish)
        
        let txPostPublisher = TxPostPublisher(successPostPublishTasks: successPostPublishers, failurePostPublishTasks: [])
        
        let sendTransactionProvider = SendTransactionProvider(txGenerator: txGenerator,
                                                              txSigner: txSigner,
                                                              txPublisher: txPublisher,
                                                              txPostPublisher: txPostPublisher,
                                                              feeProvider: application.feeProvider)
        
        let viewModel = ChooseFeeVM(sendTransactionProvider: sendTransactionProvider,
                                    defaultsProvider: application.defaults,
                                    ratesProvider: application.ratesProvider,
                                    noteProvider: application.notesProvider,
                                    confirmTimeFormatter: application.confirmMinuterFormatter,
                                    tapticService: application.tapticService,
                                    contactsProvider: application.contactsProvider)
        viewModel.userNote = userNote
        viewModel.amount = UInt64(failureTx.amount)
        let sendInputViewController = ChooseFeeViewController(viewModel: viewModel)
        sendInputViewController.mainRouter = mainRouter
        sendInputViewController.backImage = back
        sendInputViewController.conveyorView = conveyor
        mainRouter.navigationController.push(viewController: sendInputViewController)
    }
    
}
