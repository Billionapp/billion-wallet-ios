//
//  PopupView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

public enum PopupType {
    case ok
    case cancel
    case loading
    
    var imageString: String {
        switch self {
        case .ok: return "popupOk"
        case .cancel: return "popupCancel"
        case .loading: return "popupLoading"
        }
    }
}

final class PopupView: UIView {
    private let type: PopupType
    private let labelString: String
    
    static let loading = PopupView(type: .loading, labelString: "")
    
    @IBOutlet private weak var popupImage: UIImageView!
    @IBOutlet private weak var popupLabel: UILabel!
    
    init(type: PopupType, labelString: String) {
        self.type = type
        self.labelString = labelString
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        addBlur()
        setImage()
        setLabel()
        if self.type != .loading {
           addCloseGesture()
        } else {
            popupImage.rotate360Degrees()
        }
    }
    
    func showLoading() {
        UIApplication.shared.keyWindow?.addSubview(PopupView.loading)
    }
    
    func dismissLoading() {
        PopupView.loading.close()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
    }
    
    func setImage()  {
        popupImage?.image = UIImage.init(named: type.imageString)
    }
    
    func setLabel() {
        popupLabel?.text = labelString
    }
    
    func addCloseGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        self.addGestureRecognizer(tap)
    }
    
    @objc func close() {
        self.removeFromSuperview()
    }
}

extension UIView {
    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let view = Bundle.main.loadNibNamed(String(describing: type(of: self)).nibName(), owner: self, options: nil)?[0] as? T else {
                return nil
            }
        self.addFillerSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func addBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.93
        self.insertSubview(blurEffectView, at: 0)
    }
}
