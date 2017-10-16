//
//  FilterView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol FilterViewDelegate: class {
    func didRemoveFilters()
    func didAddFilter(_ filter: FilterView.Filter)
}

class FilterView: LoadableFromXibView {
    
    struct Filter {
        let sended: Bool?
        let selectedDate: Date?
    }
    
    weak var output: FilterViewDelegate?
    
    var firstEnterDate: Date!
    var selectedDate: Date?
    var currentFilter: Filter?
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M.dd"
        return dateFormatter
    }
    
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var receivedButton: UIButton!
    @IBOutlet weak var sendedButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var labelPositionConstraint: NSLayoutConstraint!
    
    init(output: FilterViewDelegate, firstEnterDate: Date, currentFilter: Filter?) {
        self.output = output
        self.firstEnterDate = firstEnterDate
        self.currentFilter = currentFilter
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func xibSetup() {
        super.xibSetup()
        receivedButton.layer.cornerRadius = receivedButton.frame.size.height / 2
        receivedButton.layer.masksToBounds = true
        sendedButton.layer.cornerRadius = sendedButton.frame.size.height / 2
        sendedButton.layer.masksToBounds = true
        sliderView.layer.cornerRadius = 20
        sliderView.layer.masksToBounds = true
        slider.setThumbImage(#imageLiteral(resourceName: "Thumb"), for: .normal)
        
        minLabel.text = dateFormatter.string(from: firstEnterDate)
        maxLabel.text = dateFormatter.string(from: Date())
        
        applyCurrentFilter()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func applyCurrentFilter() {
        
        sliderLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: firstEnterDate.timeIntervalSince1970 + abs(firstEnterDate.timeIntervalSinceNow) / 2))
        
        guard let currentFilter = currentFilter else {
            return
        }
        
        if let sended = currentFilter.sended {
            receivedButton.alpha = sended ? 0.5 : 1
            sendedButton.alpha = sended ? 1 : 0.5
        }
        
        if let timestamp = currentFilter.selectedDate {
            selectedDate = timestamp
            let timeDelta = abs(firstEnterDate.timeIntervalSinceNow)
            slider.value = Float(timestamp.timeIntervalSince(firstEnterDate) / timeDelta)
            sliderLabel.text = dateFormatter.string(from: timestamp)
            
            let sliderWidth = slider.frame.size.width - 20
            let sliderPosition = sliderWidth * CGFloat(slider.value)
            labelPositionConstraint.constant = sliderPosition - sliderWidth / 2
            view.layoutIfNeeded()
        }
    }
    
    fileprivate func isIncomingSelected() -> Bool? {
        guard sendedButton.alpha == 1 || receivedButton.alpha == 1 else {
            return nil
        }
        return sendedButton.alpha == 1
    }
    
    @objc func didTapBackground() {
        let filter = Filter(sended: isIncomingSelected(), selectedDate: selectedDate)
        output?.didAddFilter(filter)
        removeFromSuperview()
    }
    
    @IBAction func sliderDidChange(_ sender: UISlider) {
        let sliderWidth = slider.frame.size.width - 20
        let sliderPosition = sliderWidth * CGFloat(sender.value)
        labelPositionConstraint.constant = sliderPosition - sliderWidth / 2
        view.layoutIfNeeded()
        minLabel.isHidden = sender.value < 0.15
        maxLabel.isHidden = sender.value > 0.85
                
        let selectedDateInterval = firstEnterDate.timeIntervalSince1970 + abs(firstEnterDate.timeIntervalSinceNow) * Double(sender.value)
        selectedDate = Date(timeIntervalSince1970: selectedDateInterval)
        sliderLabel.text = dateFormatter.string(from: selectedDate!)
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        output?.didRemoveFilters()
        removeFromSuperview()
    }

    @IBAction func receivedPressed(_ sender: UIButton) {
        receivedButton.alpha = 1
        sendedButton.alpha = 0.5
    }
    
    @IBAction func sendedPressed(_ sender: UIButton) {
        receivedButton.alpha = 0.5
        sendedButton.alpha = 1
    }
}
