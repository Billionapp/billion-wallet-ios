//
//  BillionKeyboardView.swift
//  Billion Keyboard
//
//  Created by Evolution Group Ltd on 16.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol BillionKeyboardDelegate: class {
    func numberPressed(_ num: Int)
    func deletePressed()
    func changeCurrencyPressed(currency: CurrencyButtonState)
    func deleteAllPressed()
    func commaPressed()
}

class BillionKeyboardView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var commaLabel: UILabel?
    @IBOutlet weak var zeroDigitLabel: UILabel?
    @IBOutlet weak var zeroButton: NumberKeyButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var currencySymbolButton: ChangeCurrencyButton!
    
    var pressTimer: Timer?
    var currencies = [Currency]()
    var choosenCurrency: Currency?
    var currency = CurrencyButtonState.localCurrency
    weak var delegate: BillionKeyboardDelegate?
    var textField: UITextField?
    private var commaLongPress: UILongPressGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        configureGestures()
        configureComma()
        localizeDecimalSeparator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromXib()
        addSubview(view)
        addFillerSubview(view)
    }
    
    private func localizeDecimalSeparator() {
        let separator = Locale.current.decimalSeparator ?? "."
        commaLabel?.text = separator
    }
    
    private func configureGestures() {
        let deleteLongPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressDelete(_:)))
        commaLongPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressComma(_:)))
        deleteLongPress.minimumPressDuration = 0.3
        deleteLongPress.numberOfTouchesRequired = 1
        deleteLongPress.allowableMovement = 0.1
        commaLongPress?.minimumPressDuration = 0.3
        commaLongPress?.numberOfTouchesRequired = 1
        commaLongPress?.allowableMovement = 0.1
        deleteButton.addGestureRecognizer(deleteLongPress)
        zeroButton.addGestureRecognizer(commaLongPress!)
    }
    
    private func loadViewFromXib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)).keyboardNibName(), bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    private func configureComma() {
        commaLabel?.isHidden = !isLocalCurrency
        commaLongPress?.isEnabled = isLocalCurrency
    }
    
    var isLocalCurrency = true {
        didSet {
            currency = isLocalCurrency ? .localCurrency : .satoshi
        }
    }
    
    //MARK: - Actions
    @IBAction func numberTapped(_ sender: UIButton) {
        delegate?.numberPressed(sender.tag)
    }
    
    @IBAction func changeCurrencyTapped(_ sender: Any) {
        changeCurrencyButtonImage()
        isLocalCurrency = !isLocalCurrency
        configureComma()
        delegate?.changeCurrencyPressed(currency: currency)
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        delegate?.deletePressed()
    }
    
    @objc func handleLongPressDelete(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began  else {return}
        delegate?.deleteAllPressed()
    }
    
    @objc func handleLongPressComma(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began  else {return}
        delegate?.commaPressed()
    }
}

//MARK: - Private methods
extension BillionKeyboardView {
     func changeCurrencyButtonImage() {
        currencySymbolButton.changeTitle(with: choosenCurrency!.symbol)
    }
}

extension String {
    func keyboardNibName() -> String {
        let height = UIScreen.main.bounds.size.height
        
        guard height == 812 else {return "\(self)"}
        return "\(self)X"
    }
}
