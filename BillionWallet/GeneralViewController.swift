
//  GeneralViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GeneralViewController: BaseViewController<GeneralVM>, UIGestureRecognizerDelegate, UIPreviewInteractionDelegate, UIViewControllerPreviewingDelegate {
  
    typealias LocalizedStrings = Strings.General
  
    enum Position: String {
        case center
        case hidden
        case bottom
        case transition
    }
  
    weak var mainRouter: MainRouter?
  
    fileprivate var isViewAppear = false
    fileprivate var bottomHeight: CGFloat!
    fileprivate var position: Position = .center
    fileprivate var gradientView: UIView!
    fileprivate var bottomArea: CGFloat = Layout.model.height + Layout.model.offset + Layout.model.spacing
    var noNetworkPopup: PopupView!
    private var longPress: UILongPressGestureRecognizer!
  
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var contactsButton: UIButton!
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var centralView: UIView!
    @IBOutlet weak var topCentralView: UIView!
    @IBOutlet weak var bottomCentralView: UIView!
    @IBOutlet weak var txCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var panGasture: UIPanGestureRecognizer!
    @IBOutlet var dragCollectionGesture: DelayedGestureRecognizer!
    @IBOutlet weak var addContactButton: GradientButton!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var sendImageView: UIImageView!
    @IBOutlet weak var receiveImageView: UIImageView!
    @IBOutlet weak var sendView: TouchButtonView!
    @IBOutlet weak var receiveView: TouchButtonView!
    @IBOutlet var superviewPanGesture: UIPanGestureRecognizer!
    private var syncLoader: UIActivityIndicatorView?
    fileprivate var balanceViewRectCache: CGRect? = nil
    var previewInteraction: UIPreviewInteraction!
    var conveyorView: TouchConveyorView!
    var centralHeightConstant: CGFloat = 0
    var centralScaleFactor: CGFloat = 1
    var collectionOffsetAggregated: CGFloat = 0
    let pumpDelay = 0.1
  
    @IBOutlet weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
  
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }
  
    override func configure(viewModel: GeneralVM) {
        viewModel.delegate = self
        viewModel.cellDelegate = self
    }
  
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dragCollectionGesture.delayedDelegate = self
        txCollectionView.panGestureRecognizer.require(toFail: dragCollectionGesture)
        removeSwipeDownGesture()
        setupGradientView()
        setupTxCollection()
        setupContactsTable()
        setupBalance()
        setupPreviewDelegates()
        viewModel.restoreIfNeeded()
        setupButtons()
        animateDarkGradient()
        localize()
        viewModel.updateHistory(nil)
        setupLongPressGesture()
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupLockView()
        superviewPanGesture.isEnabled = false
        DispatchQueue.global().async {
            self.viewModel.getContacts()
        }
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppear = true
        unsetConveyorView()
        setupConveyorView()
        //FIXME: Please save this order of calls, before conveyor refactoring.
        showAddContactButtonIfNeeded(show: self.position == .bottom)
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        dragCompletion()
        isViewAppear = false
    }
  
    private func localize() {
        sendLabel.text = LocalizedStrings.send
        receiveLabel.text = LocalizedStrings.receive
        addContactButton.setTitle(LocalizedStrings.addContact, for: .normal)
    }
  
    private func setupTxCollection() {
        contactsTableView.isHidden = true
        centralHeightConstant = bottomCollectionConstraint.constant
        dragCollectionGesture.isEnabled = false
        if #available(iOS 11.0, *) {
            txCollectionView.contentInsetAdjustmentBehavior = .never
        }
        txCollectionView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        txCollectionView.register(UINib(nibName: "TxCell".nibNameForCell(), bundle: nil), forCellWithReuseIdentifier: "TxCell")
        txCollectionView.dataSource = viewModel.txsDataManager
        txCollectionView.delegate = viewModel.txsDataManager
        txCollectionView.contentInset.top = Layout.model.offset / 2
        txCollectionView.contentInset.bottom = Layout.model.offset
        txCollectionView.allowsSelection = false
        txCollectionView.isScrollEnabled = false
        bottomHeight = bottomCollectionConstraint.constant
    }

    private func setupContactsTable () {
        if #available(iOS 11.0, *) {
            contactsTableView.contentInsetAdjustmentBehavior = .never
        }
        contactsTableView.dataSource = viewModel.contactsDataSource
        contactsTableView.delegate = viewModel.contactsDataSource
        contactsTableView.emptyDataSetSource = viewModel.contactsDataSource
        contactsTableView.register(UINib(nibName: "ContactCell".nibNameForCell(), bundle: nil), forCellReuseIdentifier: "ContactCell")
    }
    
    private func setupLongPressGesture() {
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(openProfile))
        longPress.minimumPressDuration = 0.0
        balanceViewContainer.addGestureRecognizer(longPress)
    }
  
    fileprivate func setupLockView() {
        if viewModel.isTouchIdEnabled {
            unlockButton.setImage(#imageLiteral(resourceName: "TouchID"), for: .normal)
            if #available(iOS 11.0, *) {
                if TouchIDManager().faceIdIsAvaliable(){
                    unlockButton.setImage(#imageLiteral(resourceName: "FaceID"), for: .normal)
                }
            }
        } else {
            unlockButton.setImage(#imageLiteral(resourceName: "Lock"), for: .normal)
        }
        unlockButton.isHidden = !viewModel.isLocked
        contactsButton.isHidden = viewModel.isLocked
    }
  
    fileprivate func  setupGradientView() {
        let gradientHeight = Layout.model.height * 6 + Layout.model.spacing * 7
        gradientView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: gradientHeight))
        gradientView.isUserInteractionEnabled = false
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.frame
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientView.layer.insertSublayer(gradient, at: 0)
        view.addSubview(gradientView)
        view.bringSubview(toFront: gradientView)
    }
  
    fileprivate func setupBalance() {
        billionBalanceView.frame =  balanceViewContainer.bounds
        balanceViewContainer.addSubview(billionBalanceView)
    }
  
    fileprivate func setupButtons() {
        sendImageView.applyGradient(colours: [Color.buttonTop, Color.buttonBottom])
        sendImageView.layer.standardCornerRadius()
        receiveImageView.applyGradient(colours: [Color.buttonTop, Color.buttonBottom])
        receiveImageView.layer.standardCornerRadius()
    }
  
    fileprivate func setupPreviewDelegates() {
        /// FIXME: Todo dinamic blur
        /*
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.sendView)
        }
        previewInteraction = UIPreviewInteraction(view: sendView)
        previewInteraction.delegate = self
        */
        sendView.setDelegate(self)
        receiveView.setDelegate(self)
    }
  
    func setupConveyorView() {
        if conveyorView != nil {
            conveyorView.removeFromSuperview()
            conveyorView = nil
        }
        self.conveyorView = TouchConveyorView(frame: UIScreen.main.bounds)
        self.conveyorView.touchDelegate = self
        self.conveyorView.hitDelegate = self
        self.conveyorView.isUserInteractionEnabled = true
        UIApplication.shared.keyWindow!.addSubview(self.conveyorView)
    }
  
    func unsetConveyorView() {
        guard conveyorView != nil else {
            return
        }
        conveyorView.removeFromSuperview()
        conveyorView = nil
    }
  
    // MARK: Actions
    @IBAction func receiveAction() {
        let back = captureScreen(view: view)
        mainRouter?.showChooseSenderView(back: back, conveyor: conveyorView)
    }
  
    @IBAction func sendAction() {
        let back = captureScreen(view: view)
        mainRouter?.showChooseReceiver(back: back, conveyor: conveyorView)
    }
  
    @IBAction func contactsAction() {
        contactsButton.isSelected = (position == .center)
        if position == .center {
            superviewPanGesture.isEnabled = true
            performPositionChanging(position: .bottom)
        } else {
            superviewPanGesture.isEnabled = false
            performPositionChanging(position: .center)
            setupConveyorView()
        }
    }
  
    @IBAction func filtersAction(_ sender: UIButton) {
        unsetConveyorView()
        let fitstEnterDate = viewModel.defaultsProvider?.firstLaunchDate ?? Date()
        let filterView = FilterView(output: viewModel, firstEnterDate: fitstEnterDate, currentFilter: viewModel.currentFilter)
        UIApplication.shared.keyWindow?.addSubview(filterView)
    }
  
    @IBAction func addContactPressed(_ sender: UIButton) {
        unsetConveyorView()
        let back = captureScreen(view: view)
        mainRouter?.showAddContactView(back: back)
    }
  
    @IBAction func settingsAction() {
        unsetConveyorView()
        let back = captureScreen(view: view)
        mainRouter?.showSettingsView(back: back)
    }
  
    @IBAction func lockButtonPressed(_ sender: UIButton) {
        unsetConveyorView()
        mainRouter?.showPasscodeView(passcodeCase: .lock, output: viewModel)
    }
    
    @objc
    func openProfile() {
        switch longPress.state {
        case .began, .changed:
            billionBalanceView.alpha = 0.7
        default:
            billionBalanceView.alpha = 1.0
            unsetConveyorView()
            let image = captureScreen(view: view)
            mainRouter?.showProfileView(back: image)
        }
    }
  
    @IBAction func didDragPanel(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
      
        switch sender.state {
        case .began:
            bottomHeight = bottomCollectionConstraint.constant
        case .changed:
            guard bottomHeight - translation.y >= 0 else {
                return
            }
            bottomCollectionConstraint.constant = bottomHeight - translation.y
            view.layoutIfNeeded()
          
        case .ended:
            if bottomCollectionConstraint.constant > view.frame.size.height / 2 {
                performPositionChanging(position: .transition)
            } else {
                contactsAction()
            }
          
        default:
            break
        }
    }
  
    @IBAction func dragCollection(_ sender: DelayedGestureRecognizer) {
        dragCompletion()
    }
  
    func animateDarkGradient() {
        ///Dinamic top dark animation
        let blurInterval = 2 * (Layout.model.height + Layout.model.spacing)
        let gradientHeight = Layout.model.height * 6 + Layout.model.spacing * 7
        let yMinGradientHeight: CGFloat = Layout.model.height * 0.8
        var y: CGFloat
        let isTen = Layout.model == .ten
        let yPosition = isTen ? CGFloat(-15) : CGFloat(0)
        if txCollectionView.frame.origin.y > yPosition {
            y = isTen ? CGFloat(30) : CGFloat(txCollectionView.frame.origin.y + 20)
        } else {
            let numberOfBubbles = isTen ? CGFloat(11) : CGFloat(9)
            y = UIScreen.main.bounds.height - (Layout.model.offset + Layout.model.spacing * numberOfBubbles + Layout.model.height * numberOfBubbles)
        }
      
        if centralView.frame.size.height < centralHeightConstant {
            let factor = centralView.frame.size.height/blurInterval
            var height = factor * gradientHeight + yMinGradientHeight
            if height < yMinGradientHeight { height = yMinGradientHeight }
            UIView.animate(withDuration: 0.01, animations: {
                self.gradientView.layer.sublayers?.first?.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: height)
            })
        } else if centralHeightConstant == centralView.frame.size.height {
            UIView.animate(withDuration: 0.01, animations: {
                self.gradientView.layer.sublayers?.first?.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: gradientHeight)
            })
        }
    }
  
    func dragCompletion() {
        if bottomCollectionConstraint.constant > Layout.model.height + Layout.model.spacing {
            performPositionChanging(position: .center)
        } else {
            performPositionChanging(position: .hidden)
        }
    }
  
    func performPositionChanging(position: Position) {
        var nextPosition = position
      
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            switch nextPosition {
            
            case .center:
                nextPosition = .center
                self.centralView.alpha = 1
                self.contactsButton.isSelected = false
                self.filtersButton.alpha = 0
                self.settingsButton.alpha = 1
                self.bottomCollectionConstraint.constant = self.centralHeightConstant
                self.showAddContactButtonIfNeeded(show: false)
                self.txCollectionView.isUserInteractionEnabled = true
                if self.centralScaleFactor < 1 {
                    self.centralView.transform = CGAffineTransform.identity
                }
                self.txCollectionView.isScrollEnabled = false
                let txOnScreen = Layout.model == .ten ? 10 : 8
                self.dragCollectionGesture.isEnabled = self.viewModel.filteredItems.count >= txOnScreen
              
            case .hidden:
                nextPosition = .hidden
                self.bottomCollectionConstraint.constant = 0
                self.centralView.alpha = 0
                if self.centralScaleFactor > 0 {
                    self.centralView.transform = CGAffineTransform(scaleX: 0, y: 0)
                }
                self.txCollectionView.isScrollEnabled = true
                self.dragCollectionGesture.isEnabled = false
              
            case .bottom:
                nextPosition = .bottom
                self.contactsTableView.isHidden = false
                self.bottomCollectionConstraint.constant = CGFloat(4 * (Layout.model.height + Layout.model.spacing) + self.centralHeightConstant)
                self.txCollectionView.isUserInteractionEnabled = false
                self.showAddContactButtonIfNeeded(show: true)
              
            case .transition:
                nextPosition = .transition
                var topShift:CGFloat = 82
                switch Layout.model {
                    case .seven:
                        topShift = 84
                    case .ten:
                        topShift = 95
                    case .sevenPlus:
                        topShift = 82
                    case .five, .four:
                        topShift = 84
                }
                self.centralView.alpha = 0
                self.bottomCollectionConstraint.constant = self.view.frame.height + self.centralHeightConstant - topShift
    
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.position = nextPosition
            self.animateDarkGradient()
            self.txCollectionView.isScrollEnabled = true
            if nextPosition == .transition {
                self.unsetConveyorView()
                let image = captureScreen(view: self.view)
                self.mainRouter?.showContactsView(output: nil, mode: .default, back:image)
                self.performPositionChanging(position: .center)
            }
            self.contactsTableView.isHidden = nextPosition != .bottom
        })
    }
  
    fileprivate func showAddContactButtonIfNeeded(show: Bool) {
        guard viewModel.contacts.count < 4 else {
            showAddContact(show: false)
            return
        }
      
        showAddContact(show: show)
    }
  
    fileprivate func showAddContact(show: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.addContactButton.alpha = show ? 1 : 0
            self.plusLabel.alpha = show ? 1 : 0
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == txCollectionView {
            switch position {
            case .hidden:
                let txOnScreen = Layout.model == .ten ? 10 : 8
                if self.viewModel.filteredItems.count >= txOnScreen &&
                    scrollView.contentOffset.y < -11 {
                  
                    performPositionChanging(position: .center)
                    dragCollectionGesture.isEnabled = true
                }
            default:
                break
            }
        }
        animateDarkGradient()
    }
  
    // MARK: UIPreviewInteractionDelegate
    func previewInteractionShouldBegin(_ previewInteraction: UIPreviewInteraction) -> Bool {
        return true
    }
  
    func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdatePreviewTransition transitionProgress: CGFloat, ended: Bool) {
      
        guard let bubbleView = previewInteraction.view else {
            previewInteraction.cancel()
            return
        }
        let gridStep = CGFloat(16.0)
        let touchBump = CGFloat(1.04)
        let w = (bubbleView.frame.width*touchBump / 2)
        let normalizedProgress = transitionProgress * ( gridStep - 4) / w  + touchBump
      
        if ended {
            UIView.animate(withDuration: 0.1, animations: {
                bubbleView.subviews.forEach { (subview) in
                    subview.transform = CGAffineTransform(scaleX: normalizedProgress, y: normalizedProgress)
                }
            }, completion: { _ in
                self.sendAction()
                previewInteraction.view?.subviews.forEach { (subview) in
                    subview.transform = CGAffineTransform.identity
                }
            })
        } else {
            bubbleView.subviews.forEach { (subview) in
                subview.transform = CGAffineTransform(scaleX: normalizedProgress, y: normalizedProgress)
            }
        }
    }
  
    func previewInteractionDidCancel(_ previewInteraction: UIPreviewInteraction) {
        previewInteraction.view?.subviews.forEach { (subview) in
            subview.transform = CGAffineTransform.identity
        }
    }
  
    //MARK: UIViewControllerPreviewingDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        previewingContext.sourceRect = self.sendImageView.frame
        let new = UIViewController()
        return new
    }
  
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: nil)
    }
}

// MARK: - DelayedGestureRecognizerDelegate
extension GeneralViewController: DelayedGestureRecognizerDelegate {
    func didMove(_ pDiff: CGPoint) {
        if pDiff.y > 0 {
            if centralHeightConstant / 2 - pDiff.y < 0 {
                dragCollectionGesture.end()
                dragCollectionGesture.isEnabled = false
                dragCompletion()
            }
          
            let scale = CGFloat(1 - pDiff.y * 2 / self.centralHeightConstant)
            self.centralScaleFactor = scale > 0.1 ? scale : CGFloat(0)
            self.centralView.transform = CGAffineTransform(scaleX: self.centralScaleFactor, y: self.centralScaleFactor)
            self.bottomCollectionConstraint.constant = max(self.centralHeightConstant - pDiff.y * 2, 0)
            self.centralView.alpha = self.centralScaleFactor
            self.view.layoutIfNeeded()
        } else if pDiff.y < 0 {
            dragCompletion()
        }
    }
}

// MARK: - TxCellDelegate

extension GeneralViewController: TxCellDelegate {
    func bubbleButtonPressed(_ sender: TxCell) {
        self.unsetConveyorView()
        let image = captureScreen(view: view)
        let rect = txCollectionView.convert(sender.frame, to: nil)
        let cellY = rect.origin.y + sender.frame.size.height
        viewModel.showDetails(for: viewModel.itemForIdentity(sender.identity), cellY: cellY, backImage: image)
    }
}

// MARK: - GeneralVMDelegate

extension GeneralViewController: GeneralVMDelegate {
    func didSelectContact(_ contact: ContactProtocol) {
        let back = captureScreen(view: view)
        mainRouter?.showContactCardView(contact: contact, back: back)
    }
  
    func willUpdateItems(_ updater: HistoryUpdater) {
        if updater.updateCount == 0 {
            return
        }
      
        self.txCollectionView.performBatchUpdates({
            do {
                try self.viewModel.commitUpdates(updater)
            } catch let error {
                Logger.error("Could not commit batch updates: \(error.localizedDescription)")
                return
            }
          
            if updater.batchDeletedIndexes.count > 0 {
                let indexPaths = updater.batchDeletedIndexes.map { IndexPath(row: $0, section: 0) }
                self.txCollectionView.deleteItems(at: indexPaths)
            }
            if updater.batchInsertIndexes.count > 0 {
                let indexPaths = updater.batchInsertIndexes.map { IndexPath(row: $0, section: 0) }
                self.txCollectionView.insertItems(at: indexPaths)
            }
        }, completion: { (complete) in
            if updater.batchUpdateIndexes.count > 0 {
                let indexPaths = updater.batchUpdateIndexes.map { IndexPath(row: $0, section: 0) }
                let filteredPaths = indexPaths.filter { $0.row < self.viewModel.filteredItems.count }
                self.txCollectionView.reloadItems(at: filteredPaths)
            }
        })
      
        DispatchQueue.main.async {
            let txOnScreen = Layout.model == .ten ? 10 : 8
            if self.viewModel.filteredItems.count < txOnScreen {
                self.dragCollectionGesture.isEnabled = false
                self.txCollectionView.isScrollEnabled = false
            } else {
                self.dragCollectionGesture.isEnabled = true
                self.txCollectionView.isScrollEnabled = true
            }
        }
    }
  
    func didReceiveContacts() {
        DispatchQueue.main.async {
            self.contactsTableView.reloadData()
        }
    }
  
    func didChangeLockStatus(_ isLocked: Bool) {
        setupLockView()
    }
  
    func didChangeIsTouchIdEnabled(_ isTouchIdEnabled: Bool) {
        setupLockView()
    }
  
    func setConveyorAfterUnlock() {
        setupConveyorView()
    }
}

extension GeneralViewController: TouchButtonViewDelegate {
    func touchEnded(_ sender: UIView) {
        if sender == sendView {
            self.sendAction()
        } else if sender == receiveView {
            self.receiveAction()
        }
    }
}

extension GeneralViewController: TouchConveyorDelegate {
    func touchViewTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sendView == self.view.hitTest((touches.first?.location(in: self.view))!, with: event) {
            sendView.touchesBegan(touches, with: event)
        } else
        if receiveView == self.view.hitTest((touches.first?.location(in: self.view))!, with: event) {
            receiveView.touchesBegan(touches, with: event)
        } else {
            sendView.touchesCancelled(touches, with: event)
            receiveView.touchesCancelled(touches, with: event)
        }
    }
  
    func touchViewTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sendView == self.view.hitTest((touches.first?.location(in: self.view))!, with: event) {
            sendView.touchesMoved(touches, with: event)
            if touches.first!.force > 1.5 {
                viewModel.tapticService.selectionTaptic(capability:
                    self.traitCollection.forceTouchCapability == .available)
                sendView.touchesEnded(touches, with: event)
                sendAction()
            }
        } else
        if receiveView == self.view.hitTest((touches.first?.location(in: self.view))!, with: event) {
            receiveView.touchesMoved(touches, with: event)
            if touches.first!.force > 1.5 {
                viewModel.tapticService.selectionTaptic(capability:
                    self.traitCollection.forceTouchCapability == .available)
                receiveView.touchesEnded(touches, with: event)
                receiveAction()
            }
        } else {
            sendView.touchesCancelled(touches, with: event)
            receiveView.touchesCancelled(touches, with: event)
        }
    }
  
    func touchViewTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sendView == self.view.hitTest((touches.first?.location(in: self.view))!, with: event) {
            sendView.touchesEnded(touches, with: event)
            unsetConveyorView()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + pumpDelay) {
                self.sendAction()
            }
        } else
        if receiveView == self.view.hitTest((touches.first?.location(in: self.view))!, with: event) {
            receiveView.touchesEnded(touches, with: event)
            unsetConveyorView()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + pumpDelay) {
                self.receiveAction()
            }
        } else {
            sendView.touchesCancelled(touches, with: event)
            receiveView.touchesCancelled(touches, with: event)
        }
    }
  
    func touchViewTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if sendView == self.view.hitTest((touches.first?.location(in: self.view))!, with: event) {
            sendView.transform = CGAffineTransform.identity
        } else
        if receiveView == self.view.hitTest((touches.first?.location(in: self.view))!, with: event) {
            receiveView.transform = CGAffineTransform.identity
        }
    }
}

extension GeneralViewController: HitTestDelegate {
    func test(_ point: CGPoint, with event: UIEvent?) -> Bool {
        if point.x > self.view.frame.width / 2 {
            return sendView.convert(sendView.bounds, to: self.view).contains(point)
        } else {
            return receiveView.convert(receiveView.bounds, to: self.view).contains(point)
        }
    }
}
