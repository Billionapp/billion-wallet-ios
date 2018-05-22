//
//  BuyViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class BuyViewController: BaseViewController<BuyVM>, UITableViewDelegate, UITableViewDataSource {
    
    typealias LocalizedString = Strings.Buy
    
    weak var router: MainRouter?
    @IBOutlet weak var buttonBackground: UIView!
    @IBOutlet weak var methodButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
    private var titledView: TitledView!
    
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }
    
    override func configure(viewModel: BuyVM) {
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        methodButton.setTitle(LocalizedString.paymentMethod, for: .normal)
        buttonBackground.layer.cornerRadius = Layout.model.cornerRadius
        buttonBackground.layer.masksToBounds = true
        setupTitledView()
        setupBalance()
        setupTableView()
        viewModel.getExchanges()
        viewModel.getState()
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Private methods
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedString.title
        view.addSubview(titledView)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "BuyCell".nibNameForCell(), bundle: nil), forCellReuseIdentifier: "BuyCell")
        tableView.contentInset.top = Layout.model.topContentInsets
        tableView.contentInset.bottom = view.bounds.size.height - buttonBackground.frame.origin.y
    }
    
    private func setupBalance() {
        billionBalanceView.frame =  balanceViewContainer.bounds
        balanceViewContainer.addSubview(billionBalanceView)
    }
    
    private func showAlert(with exchange: Exchange) {
        let alert = UIAlertController(title: LocalizedString.alertTitle, message: LocalizedString.alertMessage, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: LocalizedString.ok, style: .default) { action in
            guard let url = URL(string: exchange.ref_url) else {
                return
            }
            let safari = SafariViewContoller(url: url)
            safari.modalPresentationCapturesStatusBarAppearance = true
            self.present(safari, animated: true, completion: nil)
        }
        alert.addAction(ok)
        
        let cancel = UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func methodPressed(_ sender: UIButton) {
        let back = captureScreen(view: view)
        let methods = viewModel.getAvailebleMethods()
        router?.showBuyPickerView(method: viewModel.paymentMethod, methods: methods, back: back, output: viewModel)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuyCell", for: indexPath) as! BuyCell
        cell.configure(with: viewModel.models[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.model.contactCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exchange = viewModel.models[indexPath.row]
        showAlert(with: exchange.exchange)
    }

}

extension BuyViewController: BuyVMDelegate {
    
    func update() { 
        tableView.reloadData()
    }
  
    func didSelectPaymentMethod(_ method: PaymentMethod) {
        methodButton.setTitle(method.name, for: .normal)
        tableView.reloadData()
    }
    
    func didReceiveState(_ state: ExchangeState) {
        methodButton.isHidden = !state.isMethodButtonEnabled
        buttonBackground.isHidden = !state.isMethodButtonEnabled
    }
    
}
