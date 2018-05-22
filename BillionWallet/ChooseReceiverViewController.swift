//
//  ChooseReceiverViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import AudioToolbox

class ChooseReceiverViewController: BaseViewController<ChooseReceiverVM> {
    
    typealias LocalizedStrings = Strings.ChooseReceiver
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet private weak var scanQrButton: UIButton?
    @IBOutlet private weak var sendToAddressFromBufferButton: UIButton?
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var addContactButton: GradientButton!
    
    weak var mainRouter: MainRouter?
  
    private var titledView: TitledView!
    private var popup: PopupView?
    var conveyorView: TouchConveyorView!
    var behindCell: UITableViewCell?
    var behindButton: UIButton?
    
    override func configure(viewModel: ChooseReceiverVM) {
        viewModel.delegate = self
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConveyor()
        localize()
        setupTitledView()
        setupTableView()
        addGradientOnTop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getContacts()
    }
    
    // MARK: - Privates
    fileprivate func localize() {
        headerLabel.text = LocalizedStrings.toTitle
        scanQrButton?.setTitle(LocalizedStrings.scanAddress, for: .normal)
        sendToAddressFromBufferButton?.setTitle(LocalizedStrings.sendToAddressInClipboard, for: .normal)
        addContactButton.setTitle(LocalizedStrings.addButton, for: .normal)
    }
    
    fileprivate func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        titledView.subtitle = LocalizedStrings.chooseRecipientSubtitle
        titledView.closePressed = {
            self.navigationController?.popToGeneralView()
        }
        view.addSubview(titledView)
    }
    
    fileprivate func setupTableView() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.dataSource = viewModel.dataSource
        tableView.delegate = viewModel.dataSource
        tableView.emptyDataSetSource = viewModel.dataSource
        tableView.register(UINib(nibName: "ContactCell".xibCellName(), bundle: nil), forCellReuseIdentifier: "ContactCell")
        view.layoutIfNeeded()
    }
    
    fileprivate func setupConveyor() {
        if conveyorView != nil {
            conveyorView.touchDelegate = self
            conveyorView.hitDelegate = nil
        }
    }
    
    // MARK: - Actions
    @IBAction func scanQrAction() {
        mainRouter?.showScanView(resolver: viewModel.qrResolver!)
    }
    
    @IBAction func sendToAddressFromBufferAction() {
        viewModel.pasteFromClipboard()
    }
    
    @IBAction func addContactButton(_ sender: UIButton) {
        let backImage = captureScreen(view: view)
        mainRouter?.showAddContactView(back: backImage)
    }
}

// MARK: - ChooseReceiverVMDelegate

extension ChooseReceiverViewController: ChooseReceiverVMDelegate {

    func didStartContactFetch() {
        popup = PopupView(type: .loading, labelString: "")
        UIApplication.shared.keyWindow?.addSubview(popup!)
    }
    
    func didFailedToFetch(_ errorMessage: String) {
        popup?.close()
        showPopup(type: .cancel, title: errorMessage)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollResistance = 1 - scrollView.contentOffset.y / titledView.frame.height
        titledView.alpha = min(1.0, scrollResistance)
        
        if scrollResistance > 1.7 {
            navigationController?.pop()
        }
    }
    
    func didReceiveContacts() {
        tableView.reloadData()
    }
    
    func didChoosePaymentRequest(_ paymentRequest: PaymentRequest) {
        mainRouter?.showSendInputAddressView(paymentRequest: paymentRequest, userPaymentRequest: nil, failureTransaction: nil, back: backImage)
    }
    
    func didChooseContact(_ contact: PaymentCodeContactProtocol) {
        popup?.close()
        mainRouter?.showSendInputContactView(contact: contact, failureTransaction: nil, back: backImage)
    }
}

extension ChooseReceiverViewController: TouchConveyorDelegate {
    func touchViewTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        let newBehind = self.view.hitTest(touch.location(in: self.view), with: event)
        if newBehind is UITableViewCell {
            let cell = newBehind as! UITableViewCell
            cell.touchesBegan(touches, with: event)
        }
    }
    
    func touchViewTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        let newBehind = self.view.hitTest(touch.location(in: self.view), with: event)
        
        if newBehind is UIButton {
            if behindCell != nil {
                behindCell?.isSelected = false
                behindCell = nil
            }
            let button = newBehind as! UIButton
            if button != behindButton {
                behindButton?.isHighlighted = false
                button.isHighlighted = true
                behindButton = button
                viewModel.tapticService.selectionTaptic(capability:
                    self.traitCollection.forceTouchCapability == .available)
            } else {
                button.isHighlighted = true
            }
        }
        
        if newBehind is UITableViewCell {
            if behindButton != nil {
                behindButton?.isHighlighted = false
                behindButton = nil
            }
            let cell = newBehind as! UITableViewCell
            if cell != behindCell {
                behindCell?.isSelected = false
                if behindCell == nil && self.viewModel.contacts.count != 1 {
                    cell.isSelected = false
                } else {
                    cell.isSelected = true
                }
                behindCell = cell
                viewModel.tapticService.selectionTaptic(capability:
                    self.traitCollection.forceTouchCapability == .available)
                
                let position = touch.location(in: self.view)
                let height = self.view.frame.height
                let rowsCount = tableView.numberOfRows(inSection: 0)
                if position.y > height - height / 8 {
                    if cell.tag + 1 < rowsCount {
                        let indexPath = IndexPath(row: cell.tag + 1, section: 0)
                        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
                if position.y < height - height / 10 * 8 {
                    if cell.tag - 1 > 0 {
                        let indexPath = IndexPath(row: cell.tag - 1, section: 0)
                        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }
            }
        }
        
        if !(newBehind is UIButton) && !(newBehind is UITableViewCell) && !(newBehind?.superview is UITableViewCell) {
            if behindCell != nil {
                behindCell?.isSelected = false
                behindCell = nil
            }
            if behindButton != nil {
                behindButton?.isHighlighted = false
                behindButton = nil
                viewModel.tapticService.selectionTaptic(capability:
                    self.traitCollection.forceTouchCapability == .available)
            }
        }
    }
    
    func touchViewTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesEnded(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        let behind = self.view.hitTest(touch.location(in: self.view), with: event)

        if behind is UIButton {
            let button = behind as! UIButton
            button.isHighlighted = false
            button.sendActions(for: .touchUpInside)
        }
        
        if behind?.superview is UITableViewCell {
            let cell = behind?.superview as! UITableViewCell
            //cell.touchesEnded(touches, with: event)
            let indexPath = IndexPath(row: cell.tag, section: 0)
            viewModel.dataSource.tableView(tableView, didSelectRowAt: indexPath)
            cell.isSelected = false
            viewModel.tapticService.selectionTaptic(capability:
                self.traitCollection.forceTouchCapability == .available)
        }
 
        conveyorView.touchDelegate = nil
        conveyorView.removeFromSuperview()
    }
    
    func touchViewTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesCancelled(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        let behind = self.view.hitTest(touch.location(in: self.view), with: event)
        if behind?.superview is UITableViewCell {
            let cell = behind?.superview as! UITableViewCell
            cell.touchesCancelled(touches, with: event)
            cell.isSelected = false
        }
        conveyorView.touchDelegate = nil
        conveyorView.removeFromSuperview()
    }
}
