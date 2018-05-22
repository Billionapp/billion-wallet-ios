//
//  PopupView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol PopupViewDelegate: class {
    func viewDidDismiss()
}

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
    var indicator: UIActivityIndicatorView?
    
    static let loading = PopupView(type: .loading, labelString: "")
    
    weak var delegate: PopupViewDelegate?
    
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
            setTimer()
        } else {
            popupImage.isHidden = true
            indicator = UIActivityIndicatorView.init(frame: popupImage.frame)
            self.addSubview(indicator!)
            indicator!.center = self.center
            indicator!.activityIndicatorViewStyle = .whiteLarge
            indicator!.startAnimating()
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
    
    func setTimer() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.close()
        }
    }
    
    func addCloseGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        self.addGestureRecognizer(tap)
    }
    
    @objc func close() {
        self.removeFromSuperview()
        delegate?.viewDidDismiss()
    }
}

extension UIView {
    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let view = Bundle.main.loadNibNamed(xibName(), owner: self, options: nil)?[0] as? T else {
                return nil
            }
        self.addFillerSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func xibName() -> String {
        let nibName = String(describing: type(of: self)).nibName()
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            return nibName
        } else {
            return "\(type(of:self))7+"
        }
    }
    
    func addBlur() {
        let screen = captureScreen(view: UIApplication.shared.keyWindow!)
        let imageView = UIImageView(frame: self.frame)
        imageView.image = screen
        self.insertSubview(imageView, at: 0)
    }
}
