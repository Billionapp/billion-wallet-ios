//
//  ChooseSenderViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ChooseSenderViewController: BaseViewController<ChooseSenderVM> {
    
    typealias LocalizedStrings = Strings.ChooseSender
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var qrButton: UIButton!
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var fromLabel: UILabel!
    weak var router: MainRouter?
    private var titledView: TitledView!
    var conveyorView: TouchConveyorView!
    var behindCell: UITableViewCell?
    var behindButton: UIButton?

    override func configure(viewModel: ChooseSenderVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConveyor()
        setupTitledView()
        setupTableView()
        setupQrGuesture()
        localize()
        viewModel.getQRImage()
        addGradientOnTop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getContacts()
    }
    
    // MARK: - Private methods
    
    private func localize() {
        fromLabel.text = LocalizedStrings.chooseSenderFrom
        addContactButton.setTitle(LocalizedStrings.addContact, for: .normal)
    }
    
    private func setupQrGuesture() {
        let guesture = UITapGestureRecognizer(target: self, action: #selector(qrPressed))
        qrView.addGestureRecognizer(guesture)
    }
    
    private func setupConveyor() {
        if conveyorView != nil {
            conveyorView.touchDelegate = self
            conveyorView.hitDelegate = nil
        }
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.chooseSenderTitle
        titledView.subtitle = LocalizedStrings.chooseSenderSubtitle
        titledView.closePressed = {
            self.navigationController?.popToGeneralView()
        }
        view.addSubview(titledView)
    }
    
    private func setupTableView() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.dataSource = viewModel.dataSource
        tableView.delegate = viewModel.dataSource
        tableView.emptyDataSetSource = viewModel.dataSource
        tableView.register(UINib(nibName: "ContactCell".xibCellName(), bundle: nil), forCellReuseIdentifier: "ContactCell")
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions

    @objc @IBAction func qrPressed() {
        router?.showReceiveView(back: backImage)
    }
    
    @IBAction func addContactPRessed(_ sender: Any) {
        let backImage = captureScreen(view: view)
        router?.showAddContactView(back: backImage)
    }
}

// MARK: - ChooseFeeVMDelegate

extension ChooseSenderViewController: ChooseSenderVMDelegate {
    func didReceiveQRImage(_ image: UIImage?) {
        qrButton.setImage(image, for: .normal)
    }
    
    func didSelectContact(_ contact: ContactProtocol) {
        guard let contact = contact as? PaymentCodeContactProtocol else {
            return
        }
        router?.showReceiveInputView(contact: contact, back: backImage)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollResistance = 1 - scrollView.contentOffset.y / 30
        titledView.alpha = min(1.0, scrollResistance)
        
        if scrollResistance > 1.7 {
            navigationController?.pop()
        }
    }
    
    func didReceiveContacts() {
        tableView.reloadData()
    }
    
}


extension ChooseSenderViewController: TouchConveyorDelegate {
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
