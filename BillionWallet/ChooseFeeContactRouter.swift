//
//  ChooseFeeContactRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

final class ChooseFeeContactRouter {
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
    func run(contact: PaymentCodeContactProtocol, amount: UInt64, userNote: String?) {
        let txGenerator = DefaultTxGeneratorFactory(wallet: application.walletProvider,
                                                    accountManager: application.accountProvider).generatorForPCContact(contact)
        let txSigner = StandardTxSigner(walletProvider: application.walletProvider)
        let txPublisher = PCTxPublisherFactory(peerMan: application.walletProvider).publisher()
        
        var successPostPublishers = [TxPostPublish]()
        var failurePostPublishers = [TxPostPublish]()
        
        successPostPublishers.append(TxPostConnectToContact(contact: contact, contactsProvider: application.contactsProvider))
        
        let failurePostPublisher =
            TxPostPublishCreateFailureTx(failureTxProvider: application.failureTxProvider,
                                         walletProvider: application.walletProvider,
                                         contact: contact)
        failurePostPublishers.append(failurePostPublisher)
        
        let txPostPublisher = TxPostPublisher(successPostPublishTasks: successPostPublishers,
                                              failurePostPublishTasks: failurePostPublishers)
        
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
        viewModel.amount = amount
        viewModel.contact = contact
        viewModel.userNote = userNote
        let sendInputViewController = ChooseFeeViewController(viewModel: viewModel)
        sendInputViewController.backImage = back
        sendInputViewController.mainRouter = mainRouter
        sendInputViewController.conveyorView = conveyor
        mainRouter.navigationController.push(viewController: sendInputViewController)
    }
    
    func run(contact: PaymentCodeContactProtocol, failureTx: FailureTx, userNote: String?) {
        let wallet = application.walletProvider
        let txGenerator = DefaultTxGeneratorFactory(wallet: wallet,
                                                    accountManager: application.accountProvider).generatorForPCContact(contact)
        let txSigner = StandardTxSigner(walletProvider: wallet)
        let txPublisher = PCTxPublisherFactory(peerMan: application.walletProvider).publisher()
        
        var successPostPublishers = [TxPostPublish]()
        
        let sucessContactPostPublish = TxPostConnectToContact(contact: contact, contactsProvider: application.contactsProvider)
        successPostPublishers.append(sucessContactPostPublish)
        
        let successDeletePostPublisher = TxPostDeleteFailureTransaction(failureTransaction: failureTx, failureTxProvider: application.failureTxProvider)
        successPostPublishers.append(successDeletePostPublisher)
        
        let txPostPublisher = TxPostPublisher(successPostPublishTasks: successPostPublishers, failurePostPublishTasks: [])
        
        let sendTransactionProvider = SendTransactionProvider(txGenerator: txGenerator, txSigner: txSigner, txPublisher: txPublisher, txPostPublisher: txPostPublisher, feeProvider: application.feeProvider)
        
        let viewModel = ChooseFeeVM(sendTransactionProvider: sendTransactionProvider,
                                    defaultsProvider: application.defaults,
                                    ratesProvider: application.ratesProvider,
                                    noteProvider: application.notesProvider,
                                    confirmTimeFormatter: application.confirmMinuterFormatter,
                                    tapticService: application.tapticService,
                                    contactsProvider: application.contactsProvider)
        viewModel.amount = UInt64(failureTx.amount)
        viewModel.contact = contact
        viewModel.userNote = userNote
        let sendInputViewController = ChooseFeeViewController(viewModel: viewModel)
        sendInputViewController.backImage = back
        sendInputViewController.mainRouter = mainRouter
        sendInputViewController.conveyorView = conveyor
        mainRouter.navigationController.push(viewController: sendInputViewController)
    }
    
    func run(displayer: UserPaymentRequestDisplayer, contact: PaymentCodeContactProtocol, userNote: String?) {
        
        let userPaymentRequest = displayer.userPaymentRequest
        
        guard userPaymentRequest.contactID == contact.uniqueValue else {
            fatalError("Something went wrong")
        }
        
        let wallet = application.walletProvider
        let txGenerator = DefaultTxGeneratorFactory(wallet: wallet,
                                                    accountManager: application.accountProvider).generatorForPCContact(contact)
        let txSigner = StandardTxSigner(walletProvider: wallet)
        let txPublisher = DefaultTxPublisherFactory(peerMan: application.walletProvider).publisher()
        
        var successPostPublishers = [TxPostPublish]()
        var failurePostPublishers = [TxPostPublish]()
        
        successPostPublishers.append(TxPostConnectToContact(contact: contact,
                                                            contactsProvider: application.contactsProvider))
        let successPostPublish = TxPostConfirmRequest(messageSendProvider: application.messageSendProvider,
                                                      requestId: userPaymentRequest.identifier,
                                                      contact: contact)
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
        viewModel.amount = displayer.amount
        viewModel.userNote = userNote
        viewModel.contact = contact
        let sendInputViewController = ChooseFeeViewController(viewModel: viewModel)
        sendInputViewController.mainRouter = mainRouter
        sendInputViewController.backImage = back
        sendInputViewController.conveyorView = conveyor
        mainRouter.navigationController.push(viewController: sendInputViewController)
    }
}
