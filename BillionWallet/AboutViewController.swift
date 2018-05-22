//
//  AboutViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 3/19/18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController<AboutVM> {
    
    weak var router: MainRouter?
    
    typealias LocalizedStrings = Strings.About
    
    private let height = UIScreen.main.bounds.height
    private let width = UIScreen.main.bounds.width
    private let screenRect = UIScreen.main.bounds
    private let sizeOfTitles = CGFloat(32)
    private let sizeOfLabels = CGFloat(15)
    private let ethalonWidth = Layout.model != .ten ? CGFloat(414) : CGFloat(375)
    private let ethalonHeight = Layout.model != .ten ? CGFloat(736) : CGFloat(812)
    private let topShadowHeight = CGFloat(210)
    private let bottomShadowHeight = CGFloat(295)
    private let titleFrame = CGRect(x: 0, y: 92, width: 414, height: 36)
    private let phoneFrame = CGRect(x: 34, y: 44, width: 346, height: 692)
    private let forgetLabelFrame = CGRect(x: 70, y: 505, width: 276, height: 110)
    private let indicatorFrame = CGRect(x: 207, y: 633, width: 86, height: 6)
    private let cardFrame = CGRect(x: 54, y: 118, width: 306, height: 544)
    private let qrFrame = CGRect(x: 159, y: 123, width: 118, height: 118)
    private let cardToAirShift = CGFloat(-96)
    private let airToReceiveShift = CGFloat(-130)
    private let buttonRect = CGRect(x: Layout.model.offset,
                                    y: UIScreen.main.bounds.height - Layout.model.offset - Layout.model.height,
                                    width: UIScreen.main.bounds.width - Layout.model.offset * 2,
                                    height: Layout.model.height)
    private let phoneImage = UIImage(named: "AboutPhone")!
    private var phone: UIImageView!
    private var topShadowView: UIView!
    private var bottomShadowView: UIView!
    private var titleLabel: UILabel!
    private var forgetAboutLabel: UILabel!
    private var indicator: UIPageControl!
    private var button: GradientButton!
    private var card: UIImageView!
    private var phoneScreen: UIView!
    
    //Air Connectivity
    private let withReusableLabelFrame = CGRect(x: 98, y: 541, width: 219, height: 70)
    private let airScreenFrame = CGRect(x: 54, y: 22, width: 306, height: 544)
    private let findingFrame = CGRect(x: 68, y: 151, width: 170, height: 24)
    private let radarFrame = CGRect(x: 52, y: 197, width: 202, height: 202)
    private let toInstantlyFrame = CGRect(x: 92, y: 429, width: 121, height: 30)
    private var radar: LoaderView!
    private var withReusableLabel: UILabel!
    private var findingLabel: UILabel!
    private var toInstantlyLabel: UILabel!
    
    //Receive
    private let enjoyLabelFrame = CGRect(x: 75, y: 541, width: 264, height: 74)
    private let receiveButtonFrame = CGRect(x: 15, y: 429.5, width: 132, height: 45)
    private let selectionFrame = CGRect(x: 0, y: 306, width: 306, height: 58)
    private let selectedIconFrame = CGRect(x: Layout.sevenPlus.offset * 306 / 414,
                                           y: 306 + Layout.sevenPlus.offset * 306 / 414,
                                           width: Layout.sevenPlus.height * 306 / 414,
                                           height: Layout.sevenPlus.height * 306 / 414)
    private let selectedIconFrameEnd = CGRect(x: 15, y: 338, width: 28, height: 28)
    private let balanceFrame = CGRect(x: 72, y: 282, width: 161, height: 46)
    private let inputFrame = CGRect(x: 5, y: 338, width: 297, height: 202.5)
    private let receiveGenImage = UIImage(named: "ReceiveGen")!
    private var receiveGenView: UIImageView!
    private let receiveButtonImage = UIImage(named: "ReceiveButton")!
    private var receiveButtonView: UIImageView!
    private let receiveContactsImage = UIImage(named: "ReceiveContacts")!
    private var contactsView: UIImageView!
    private var selectContactView: UIView!
    private let selectedImage = UIImage(named: "SendIcon")!
    private var selectedIcon: UIImageView!
    private let balanceImage = UIImage(named: "ReceiveBalance")
    private var balanceView: UIImageView!
    private let inputImage = UIImage(named: "ReceiveInput")
    private var inputKeyboard: UIImageView!
    private var enjoyLabel: UILabel!
    private var fromLabel: UILabel!
    
    //Fee
    private let saveLabelFrame = CGRect(x: 47, y: 538, width: 306, height: 74)
    private var saveLabel: UILabel!
    private let feeBackImage = UIImage(named: "FeeBackImage")
    private var feeBackView: UIImageView!
    private let feeTimeLabelFrame = CGRect(x: 31, y: 185.5, width: 95, height: 25)
    private var feeTimeLabel: UILabel!
    private let feeTimeTitleLabelFrame = CGRect(x: 50, y: 216.5, width: 55, height: 12)
    private var feeTimeTitleLabel: UILabel!
    private let feeLabelFrame = CGRect(x: 194, y: 185.5, width: 95, height: 25)
    private var feeLabel: UILabel!
    private let feeTitleLabelFrame = CGRect(x: 212, y: 216.5, width: 55, height: 12)
    private var feeTitleLabel: UILabel!
    private let feeSatPerByteLabelFrame = CGRect(x: 165, y: 288, width: 129, height: 25)
    private var feeSatPerByteLabel: UILabel!
    private let sliderFrame = CGRect(x: 13, y: 335, width: 279, height: 23)
    @objc dynamic var feeSlider: UISlider!
    
    //Satoshi
    private let satLabelFrame = CGRect(x: 47, y: 538, width: 306, height: 74)
    private var satLabel: UILabel!
    private let satBarImage = UIImage(named: "SatoshiBar")
    private let satBarFrame = CGRect(x: 0, y: 502, width: 306, height: 45.1)
    private var satBar: UIImageView!
    private let chatViewFrame = CGRect(x: 11, y: 456, width: 284, height: 179)
    private let chatViewFirstShift = CGFloat(-43)
    private let chatViewSecondShift = CGFloat(-32)
    private var chatImage: UIImage!
    private var chatView: UIImageView!
    
    //SPV
    private let spvLabelFrame = CGRect(x: 95, y: 538, width: 225, height: 72)
    private var spvLabel: UILabel!
    private let spvBackImage = UIImage(named: "SpvBackground")
    private var spvBackView: UIImageView!
    private let spvBalanceFrame = CGRect(x: 72.4, y: 486.3, width: 161, height: 45.8)
    private var spvBalanceStatic: UIImageView!
    private var spvBalanceStaticImage = UIImage(named: "BalanceStatic")
    private var spvBalanceView: UIView!
    private let spvProgressFrame = CGRect(x: 0, y: 0, width: 161, height: 0)
    private var spvProgressView: UIView!
    private let spvIndicatorFrame = CGRect(x: 29.56, y: 4.43, width: 8.87, height: 8.87)
    private var spvIndicatorView: UIActivityIndicatorView!
    private let spvTopLabelFrame = CGRect(x: 41.4, y: 3.7, width: 88.7, height: 8.87)
    private var spvTopLabel: UILabel!
    private let spvProgressLabelFrame = CGRect(x: 14.78, y: 15, width: 131.56, height: 18)
    private var spvProgressLabel: UILabel!
    private let spvBottomLabelFrame = CGRect(x: 14.79, y: 33.26, width: 131.56, height: 8.87)
    private var spvBottomLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        initialAnimation()
    }
    
    override func configure(viewModel: AboutVM) {
        super.configure(viewModel: viewModel)
        viewModel.delegate = self
    }
    
    private func setupScene() {
        addTitles()
        addShadowedIphone()
        addIndicator()
        addButton()
    }
    
    private func addButton() {
        button = GradientButton(frame: buttonRect)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.setTitle(LocalizedStrings.nextButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(airAction), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        button.alpha = 0
        self.view.addSubview(button)
    }
    
    private func addIndicator() {
        indicator = UIPageControl(frame: adoptedFrame(frame: indicatorFrame))
        if Layout.model == .ten {
            indicator.frame = indicator.frame.offsetBy(dx: -20, dy: 70)
        }
        indicator.numberOfPages = 6
        indicator.currentPage = 0
        indicator.isUserInteractionEnabled = false
        self.view.addSubview(indicator)
    }
    
    private func addTitles() {
        titleLabel = UILabel(frame: adoptedFrame(frame: titleFrame))
        if Layout.model == .ten {
            titleLabel.frame = titleLabel.frame.offsetBy(dx: -20, dy: -20)
        }
        titleLabel.text = LocalizedStrings.titleAboutPC
        setupLabel(label: titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: sizeOfTitles, weight: .semibold)
        self.view.addSubview(titleLabel)
        
        forgetAboutLabel = UILabel(frame: adoptedFrame(frame: forgetLabelFrame))
        if Layout.model == .ten {
            forgetAboutLabel.frame = forgetAboutLabel.frame.offsetBy(dx: -20, dy: 60)
        }
        forgetAboutLabel.text = LocalizedStrings.forgetLabelAboutPC
        setupLabel(label: forgetAboutLabel)
        self.view.addSubview(forgetAboutLabel)
    }
    
    private func addShadowedIphone() {
        phone = UIImageView(frame: adoptedFrame(frame: phoneFrame))
        if Layout.model == .ten {
            phone.frame = phone.frame.offsetBy(dx: -20, dy: 0)
        }
        phone.image = phoneImage
        self.view.addSubview(phone)
        addCard()
        
        let topShadowRect = CGRect(x: 0,
                                   y: 0,
                                   width: width,
                                   height: height * topShadowHeight / ethalonHeight)
        let bottomShadowRect = CGRect(x: 0,
                                      y: height - (height * bottomShadowHeight / ethalonHeight),
                                      width: width,
                                      height: height * bottomShadowHeight / ethalonHeight)
        
        let topGradient = CAGradientLayer()
        topGradient.frame = topShadowRect
        topGradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        topShadowView = UIView(frame: topShadowRect)
        topShadowView.layer.addSublayer(topGradient)
        self.view.addSubview(topShadowView)
        
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomShadowRect.offsetBy(dx: 0, dy: -bottomShadowRect.origin.y)
        bottomGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor]
        bottomGradient.allowsGroupOpacity = false
        bottomShadowView = UIView(frame: bottomShadowRect)
        bottomShadowView.layer.addSublayer(bottomGradient)
        self.view.addSubview(bottomShadowView)
    }
    
    private func adoptedFrame(frame: CGRect) -> CGRect {
        return CGRect(x: width * frame.origin.x / ethalonWidth,
                      y: height * frame.origin.y / ethalonHeight,
                      width: width * frame.width / ethalonWidth,
                      height: height * frame.height / ethalonHeight)
    }
    
    private func setupLabel(label: UILabel) {
        label.font = UIFont.systemFont(ofSize: sizeOfLabels, weight: .semibold)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.layer.zPosition = 1
    }
    
    //MARK: CARD
    private func initialAnimation() {
        titleLabel.alpha = 0
        forgetAboutLabel.alpha = 0
        phone.alpha = 0.15
        phone.frame = phone.frame.offsetBy(dx: 0, dy: -316)
        indicator.alpha = 0
        card.alpha = 0
        button.frame = buttonRect.offsetBy(dx: 0, dy: Layout.model.height + Layout.model.offset)
        
        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseIn, animations: {
            self.titleLabel.alpha = 1
            self.phone.alpha = 1
            self.phone.frame = self.phone.frame.offsetBy(dx: 0, dy: 316)
            self.indicator.alpha = 1
        })
        UIView.animate(withDuration: 0.5, delay: 0.6, options: .curveEaseIn, animations: {
            self.forgetAboutLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
                self.card.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    self.button.frame = self.buttonRect
                }) { _ in
                    self.button.isUserInteractionEnabled = true
                    self.button.alpha = 1
                }
            }
        }
    }
    
    private func addCard() {
        card = UIImageView(frame: adoptedFrame(frame: cardFrame))
        if Layout.model == .ten {
            card.frame = card.frame.offsetBy(dx: -20, dy: 0)
        }
        card.image = UIImage(named: "AboutCard")
        self.view.addSubview(card)
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = card.bounds
        blur.alpha = 0
        card.addSubview(blur)
        
        let maskView = UIImageView(frame: adoptedFrame(frame: qrFrame))
        maskView.image = UIImage(named: "qrMask")
        card.addSubview(maskView)
        
        UIView.animate(withDuration: 2.0, delay: 2.0, options: [.repeat, .autoreverse], animations: {
            blur.alpha = 1
        })
    }
    
    //MARK: AIR CONN
    private func airConnectivityAnimation() {
        titleLabel.text = LocalizedStrings.titleAirConnectivity
        let offset = height * cardToAirShift / ethalonHeight
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.forgetAboutLabel.alpha = 0
            self.card.alpha = 0
        })
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.phone.frame = self.phone.frame.offsetBy(dx: 0, dy: offset)
            self.card.frame = self.card.frame.offsetBy(dx: 0, dy: offset)
        }) { _ in
            self.card.removeFromSuperview()
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.phoneScreen.alpha = 1
                self.withReusableLabel.alpha = 1
            }) { _ in
                self.button.removeTarget(self, action: #selector(self.airAction), for: .touchUpInside)
                self.button.addTarget(self, action: #selector(self.receiveAction), for: .touchUpInside)
                self.button.isUserInteractionEnabled = true
                self.button.alpha = 1
            }
        }
    }
    
    private func prepareForAirConnectivity() {
        phoneScreen = UIView(frame: adoptedFrame(frame: airScreenFrame))
        if Layout.model == .ten {
            phoneScreen.frame = phoneScreen.frame.offsetBy(dx: -20, dy: 0)
        }
        phoneScreen.alpha = 0
        self.view.insertSubview(phoneScreen, at: 0)
        
        findingLabel = UILabel(frame: adoptedFrame(frame: findingFrame))
        findingLabel.text = LocalizedStrings.findingLabel
        setupLabel(label: findingLabel)
        findingLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        phoneScreen.addSubview(findingLabel)
        
        toInstantlyLabel = UILabel(frame: adoptedFrame(frame: toInstantlyFrame))
        toInstantlyLabel.text = LocalizedStrings.toInstantlyLabel
        setupLabel(label: toInstantlyLabel)
        toInstantlyLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        toInstantlyLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        phoneScreen.addSubview(toInstantlyLabel)
        
        let adoptedRadarFrame = adoptedFrame(frame: radarFrame)
        radar = LoaderView(size: adoptedRadarFrame.size)
        radar.frame.origin = adoptedRadarFrame.origin
        phoneScreen.addSubview(radar)
        
        withReusableLabel = UILabel(frame: adoptedFrame(frame: withReusableLabelFrame))
        if Layout.model == .ten {
            withReusableLabel.frame = withReusableLabel.frame.offsetBy(dx: -20, dy: 60)
        }
        withReusableLabel.text = LocalizedStrings.withReusableLabel
        setupLabel(label: withReusableLabel)
        withReusableLabel.alpha = 0
        self.view.addSubview(withReusableLabel)
    }
    
    //MARK: RECEIVE
    private func receiveAnimation() {
        let offset = height * airToReceiveShift / ethalonHeight
        let screenOffset = height * (airToReceiveShift + 50) / ethalonHeight
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.phoneScreen.alpha = 0
            self.withReusableLabel.alpha = 0
            self.titleLabel.alpha = 0
        }) { _ in
            
            self.prepareForReceive()
            
            self.titleLabel.text = LocalizedStrings.titleReceive
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.titleLabel.alpha = 1
                self.phoneScreen.alpha = 1
                self.enjoyLabel.alpha = 1
            }) { _ in
                self.receiveAnimationCycle()
            }
        }
        
        UIView.animate(withDuration: 0.9, delay: 0, options: .curveEaseOut, animations: {
            self.phone.frame = self.phone.frame.offsetBy(dx: 0, dy: offset)
            self.phoneScreen.frame = self.phoneScreen.frame.offsetBy(dx: 0, dy: screenOffset)
        })
    }
    
    private func prepareForReceive() {
        withReusableLabel.removeFromSuperview()
        findingLabel.removeFromSuperview()
        toInstantlyLabel.removeFromSuperview()
        radar.removeFromSuperview()
        
        receiveButtonView = UIImageView(frame: adoptedFrame(frame: receiveButtonFrame))
        receiveButtonView.image = receiveButtonImage
        
        receiveGenView = UIImageView(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: phoneScreen.frame.size.width,
                                                   height: phoneScreen.frame.size.height))
        receiveGenView.image = receiveGenImage
        receiveGenView.addSubview(receiveButtonView)
        phoneScreen.addSubview(receiveGenView)
        
        enjoyLabel = UILabel(frame: adoptedFrame(frame: enjoyLabelFrame))
        if Layout.model == .ten {
            enjoyLabel.frame = enjoyLabel.frame.offsetBy(dx: -20, dy: 60)
        }
        enjoyLabel.text = LocalizedStrings.enjoyLabel
        setupLabel(label: enjoyLabel)
        enjoyLabel.alpha = 0
        self.view.addSubview(enjoyLabel)
        
        fromLabel = UILabel(frame: phoneScreen.frame)
        fromLabel.text = LocalizedStrings.fromLabel
        setupLabel(label: fromLabel)
        fromLabel.font = UIFont.systemFont(ofSize: sizeOfTitles, weight: .semibold)
        fromLabel.alpha = 0
        self.view.addSubview(fromLabel)
        
        contactsView = UIImageView(frame: CGRect(x: 0,
                                                 y: phoneScreen.frame.size.height / 2,
                                                 width: phoneScreen.frame.size.width,
                                                 height: phoneScreen.frame.size.height))
        contactsView.image = receiveContactsImage
        contactsView.alpha = 0
        phoneScreen.addSubview(contactsView)
        
        selectContactView = UIView(frame: adoptedFrame(frame: selectionFrame))
        let gradient = CAGradientLayer()
        gradient.colors = [Color.buttonTop.cgColor, Color.buttonBottom.cgColor]
        gradient.frame = selectContactView.bounds
        selectContactView.layer.addSublayer(gradient)
        selectContactView.alpha = 0
        contactsView.addSubview(selectContactView)
        
        selectedIcon = UIImageView(frame: adoptedFrame(frame: selectedIconFrame))
        selectedIcon.image = selectedImage
        selectedIcon.alpha = 0
        phoneScreen.addSubview(selectedIcon)
        
        inputKeyboard = UIImageView(frame: adoptedFrame(frame: inputFrame).offsetBy(dx: 0, dy: inputFrame.size.height))
        inputKeyboard.image = inputImage
        inputKeyboard.alpha = 0
        phoneScreen.addSubview(inputKeyboard)
        
        balanceView = UIImageView(frame: adoptedFrame(frame: balanceFrame))
        balanceView.image = balanceImage
        balanceView.alpha = 0
        phoneScreen.addSubview(balanceView)
        
        //Just patch bottom area
        let patchFrame = CGRect(x: phone.frame.origin.x, y: phone.frame.origin.y + phone.frame.size.height - 10, width: phone.frame.size.width, height: 100)
        let patchView = UIView(frame: patchFrame)
        patchView.backgroundColor = UIColor.black
        self.view.insertSubview(patchView, belowSubview: phone)
    }
    
    @objc private func receiveAnimationCycle() {
        
        if self.button.isUserInteractionEnabled {
            receiveGenView.alpha = 1
            receiveButtonView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.5, options: .curveEaseIn, animations: {
            self.receiveButtonView.image = UIImage(named: "ReceiveSelected")
            let factor = 1 + Layout.sevenPlus.spacing * 2 / 179
            self.receiveButtonView.transform = CGAffineTransform(scaleX: factor, y: factor)
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.receiveGenView.alpha = 0
                self.receiveButtonView.alpha = 0
                self.fromLabel.alpha = 1
                self.fromLabel.frame = self.fromLabel.frame.offsetBy(dx: 0, dy: -Layout.model.height*2/3)
                self.contactsView.frame = CGRect(x: 0,
                                                 y: 0,
                                                 width: self.phoneScreen.frame.size.width,
                                                 height: self.phoneScreen.frame.size.height)
                self.contactsView.alpha = 1
            }) { _ in
                
                self.receiveButtonView.transform = CGAffineTransform.identity
                self.receiveButtonView.image = UIImage(named: "ReceiveButton")
                
                UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseIn, animations: {
                    self.selectContactView.alpha = 1
                }) { _ in
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                        self.contactsView.alpha = 0
                        self.fromLabel.alpha = 0
                        self.selectedIcon.alpha = 1
                        self.selectedIcon.frame = self.adoptedFrame(frame: self.selectedIconFrameEnd)
                        self.inputKeyboard.alpha = 1
                        self.inputKeyboard.frame = self.adoptedFrame(frame: self.inputFrame)
                        self.balanceView.alpha = 1
                    }) { _ in
                        
                        self.contactsView.frame = CGRect(x: 0,
                                                         y: self.phoneScreen.frame.size.height / 2,
                                                         width: self.phoneScreen.frame.size.width,
                                                         height: self.phoneScreen.frame.size.height)
                        self.fromLabel.frame = self.phoneScreen.frame
                        
                        UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseIn, animations: {
                            self.selectedIcon.alpha = 0
                            self.inputKeyboard.alpha = 0
                            self.balanceView.alpha = 0
                        }) { _ in
                            
                            self.selectedIcon.frame = self.adoptedFrame(frame: self.selectedIconFrame)
                            self.inputKeyboard.frame = self.adoptedFrame(frame: self.inputFrame).offsetBy(dx: 0, dy: self.inputFrame.size.height)
                            
                            if self.indicator.currentPage == 2 {
                                if !self.button.isUserInteractionEnabled {
                                    self.button.removeTarget(self, action: #selector(self.receiveAction), for: .touchUpInside)
                                    self.button.addTarget(self, action: #selector(self.feeAction), for: .touchUpInside)
                                    self.button.isUserInteractionEnabled = true
                                    self.button.alpha = 1
                                }
                                self.receiveAnimationCycle()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func removeReceiveAnimations() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.phoneScreen.alpha = 0
            self.contactsView.alpha = 0
            self.enjoyLabel.alpha = 0
            self.fromLabel.alpha = 0
            self.titleLabel.alpha = 0
        }) { _ in
            self.phoneScreen.layer.removeAllAnimations()
            self.contactsView.removeFromSuperview()
            self.fromLabel.removeFromSuperview()
            self.enjoyLabel.removeFromSuperview()
            self.selectedIcon.removeFromSuperview()
            self.inputKeyboard.removeFromSuperview()
            self.balanceView.removeFromSuperview()
            self.receiveGenView.removeFromSuperview()
            self.receiveButtonView.removeFromSuperview()
        }
    }
    
    //MARK: FEE
    private func feeAnimation() {
        titleLabel.text = LocalizedStrings.titleFee
        saveLabel = UILabel(frame: adoptedFrame(frame: saveLabelFrame))
        if Layout.model == .ten {
            saveLabel.frame = saveLabel.frame.offsetBy(dx: -10, dy: 70)
        }
        setupLabel(label: saveLabel)
        saveLabel.text = LocalizedStrings.saveLabel
        saveLabel.alpha = 0
        view.addSubview(saveLabel)
        let offset = height * -cardToAirShift / ethalonHeight
        
        prepareForFee()
        
        UIView.animate(withDuration: 1.0, delay: 0.22, options: .curveEaseIn, animations: {
            self.phone.frame = self.phone.frame.offsetBy(dx: 0, dy: offset)
            self.phoneScreen.frame = self.phoneScreen.frame.offsetBy(dx: 0, dy: offset)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.titleLabel.alpha = 1
                self.saveLabel.alpha = 1
                self.phoneScreen.alpha = 1
                self.feeBackView.alpha = 1
                self.feeSlider.alpha = 1
                self.feeSatPerByteLabel.alpha = 1
                self.feeLabel.alpha = 1
                self.feeTitleLabel.alpha = 1
                self.feeTimeLabel.alpha = 1
                self.feeTimeTitleLabel.alpha = 1
            }) { _ in
                self.feeAnimationCycle()
            }
        }
    }
    
    private func prepareForFee() {
        feeBackView = UIImageView(frame: phoneScreen.bounds)
        feeBackView.image = feeBackImage
        feeBackView.alpha = 0
        phoneScreen.addSubview(feeBackView)
        
        feeSlider = UISlider(frame: adoptedFrame(frame: sliderFrame))
        feeSlider.alpha = 0
        phoneScreen.addSubview(feeSlider)
        configureFeeSlider()
        
        feeSatPerByteLabel = UILabel(frame: adoptedFrame(frame: feeSatPerByteLabelFrame))
        setupLabel(label: feeSatPerByteLabel)
        feeSatPerByteLabel.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        feeSatPerByteLabel.text = "155 ㋛/byte"
        feeSatPerByteLabel.alpha = 0
        phoneScreen.addSubview(feeSatPerByteLabel)
        
        feeTimeLabel = UILabel(frame: adoptedFrame(frame: feeTimeLabelFrame))
        setupLabel(label: feeTimeLabel)
        feeTimeLabel.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        feeTimeLabel.text = "≈ 10 min"
        feeTimeLabel.alpha = 0
        phoneScreen.addSubview(feeTimeLabel)
        
        feeTimeTitleLabel = UILabel(frame: adoptedFrame(frame: feeTimeTitleLabelFrame))
        setupLabel(label: feeTimeTitleLabel)
        feeTimeTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        feeTimeTitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        feeTimeTitleLabel.text = LocalizedStrings.feeTimeLabel
        feeTimeTitleLabel.alpha = 0
        phoneScreen.addSubview(feeTimeTitleLabel)
        
        feeLabel = UILabel(frame: adoptedFrame(frame: feeLabelFrame))
        setupLabel(label: feeLabel)
        feeLabel.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        feeLabel.text = "$ 12,5"
        feeLabel.alpha = 0
        phoneScreen.addSubview(feeLabel)
        
        feeTitleLabel = UILabel(frame: adoptedFrame(frame: feeTitleLabelFrame))
        setupLabel(label: feeTitleLabel)
        feeTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        feeTitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        feeTitleLabel.text = LocalizedStrings.feeTotalLabel
        feeTitleLabel.alpha = 0
        phoneScreen.addSubview(feeTitleLabel)
    }
    
    private func configureFeeSlider() {
        feeSlider.minimumValue = Float(1)
        feeSlider.maximumValue = Float(155)
        feeSlider.setValue(Float(155), animated: false)
        feeSlider.setThumbImage(#imageLiteral(resourceName: "FeeThumb"), for: .normal)
        feeSlider.minimumTrackTintColor = Color.FeeSlider.minimumSliderColor
        feeSlider.maximumTrackTintColor = Color.FeeSlider.maximumSliderColor
        feeSlider.isUserInteractionEnabled = false
    }
    
    @objc private func feeUpdateLabels() {
        let minutes = Int(1200/feeSlider.value)
        self.feeTimeLabel.text = "≈ \(minutes) min"
        self.feeLabel.text = "$ \(Int(feeSlider.value*12.5/155))"
        self.feeSatPerByteLabel.text = "\(Int(feeSlider.value)) ㋛/byte"
    }
    
    private func feeAnimationCycle() {
        UIView.animate(withDuration: 0.07, delay: 0.2, options: .curveEaseIn, animations: {
            self.feeSlider.setValue(150, animated: true)
        }) { _ in
            self.feeUpdateLabels()
            UIView.animate(withDuration: 0.075, delay: 0.0, options: .curveEaseIn, animations: {
                self.feeSlider.setValue(145, animated: true)
            }) { _ in
                self.feeUpdateLabels()
                UIView.animate(withDuration: 0.081, delay: 0.0, options: .curveEaseIn, animations: {
                    self.feeSlider.setValue(140, animated: true)
                }) { _ in
                    self.feeUpdateLabels()
                    UIView.animate(withDuration: 0.098, delay: 0.0, options: .curveEaseIn, animations: {
                        self.feeSlider.setValue(135, animated: true)
                    }) { _ in
                        self.feeUpdateLabels()
                        UIView.animate(withDuration: 0.106, delay: 0.0, options: .curveEaseIn, animations: {
                            self.feeSlider.setValue(130, animated: true)
                        }) { _ in
                            self.feeUpdateLabels()
                            UIView.animate(withDuration: 0.115, delay: 0.0, options: .curveEaseIn, animations: {
                                self.feeSlider.setValue(120, animated: true)
                            }) { _ in
                                self.feeUpdateLabels()
                                UIView.animate(withDuration: 0.13, delay: 0.0, options: .curveEaseIn, animations: {
                                    self.feeSlider.setValue(105, animated: true)
                                }) { _ in
                                    self.feeUpdateLabels()
                                    UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
                                        self.feeSlider.setValue(80, animated: true)
                                    }) { _ in
                                        self.feeUpdateLabels()
                                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                                            self.feeSlider.setValue(50, animated: true)
                                        }) { _ in
                                            self.feeUpdateLabels()
                                            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                                                self.feeSlider.setValue(20, animated: true)
                                            }) { _ in
                                                self.feeUpdateLabels()
                                                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                                                    self.feeSlider.setValue(40, animated: true)
                                                }) { _ in
                                                    self.feeUpdateLabels()
                                                    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                                                        self.feeSlider.setValue(60, animated: true)
                                                    }) { _ in
                                                        
                                                        if self.indicator.currentPage == 3 {
                                                            if !self.button.isUserInteractionEnabled {
                                                                self.button.removeTarget(self, action: #selector(self.feeAction), for: .touchUpInside)
                                                                self.button.addTarget(self, action: #selector(self.satoshiAction), for: .touchUpInside)
                                                                self.button.isUserInteractionEnabled = true
                                                                self.button.alpha = 1
                                                            }
                                                            self.feeAnimationCycle()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func removeFeeAnimations(completion: @escaping () -> Void) {
        let offset = height * cardToAirShift / ethalonHeight
        
        UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
            self.phoneScreen.alpha = 0
            self.saveLabel.alpha = 0
            self.titleLabel.alpha = 0
            self.phone.frame = self.phone.frame.offsetBy(dx: 0, dy: offset)
            self.phoneScreen.frame = self.phoneScreen.frame.offsetBy(dx: 0, dy: offset)
            
        }) { _ in
            self.phoneScreen.layer.removeAllAnimations()
            self.saveLabel.removeFromSuperview()
            self.feeBackView.removeFromSuperview()
            self.feeSlider.removeFromSuperview()
            self.feeSatPerByteLabel.removeFromSuperview()
            self.feeLabel.removeFromSuperview()
            self.feeTitleLabel.removeFromSuperview()
            self.feeTimeLabel.removeFromSuperview()
            self.feeTimeTitleLabel.removeFromSuperview()
            completion()
        }
    }
    
    //MARK: SATOSHI
    private func satoshiAnimation() {
        titleLabel.text = LocalizedStrings.titleSatoshi
        satLabel = UILabel(frame: adoptedFrame(frame: satLabelFrame))
        if Layout.model == .ten {
            satLabel.frame = satLabel.frame.offsetBy(dx: -10, dy: 60)
        }
        setupLabel(label: satLabel)
        satLabel.text = LocalizedStrings.satLabel
        satLabel.alpha = 0
        view.addSubview(satLabel)
        
        prepareForSatoshi()
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.titleLabel.alpha = 1
            self.satLabel.alpha = 1
        }) { _ in
            self.satoshiAnimationCycle()
        }
    }
    
    private func prepareForSatoshi() {
        satBar = UIImageView(frame: adoptedFrame(frame: satBarFrame))
        satBar.image = satBarImage
        satBar.layer.zPosition = 1
        phoneScreen.addSubview(satBar)
        
        switch Locale.current.identifier.split(separator: "_").first {
            case "ru":
                chatImage = UIImage(named: "SatoshiChatRu")
            default:
                chatImage = UIImage(named: "SatoshiChatEn")
        }
        chatView = UIImageView(frame: adoptedFrame(frame: chatViewFrame))
        chatView.image = chatImage
        phoneScreen.addSubview(chatView)
    }
    
    private func satoshiAnimationCycle() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.phoneScreen.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseIn, animations: {
                let firstShift = self.height * self.chatViewFirstShift / self.ethalonHeight
                self.chatView.frame = self.chatView.frame.offsetBy(dx: 0, dy: firstShift)
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseIn, animations: {
                    let secondShift = self.height * self.chatViewSecondShift / self.ethalonHeight
                    self.chatView.frame = self.chatView.frame.offsetBy(dx: 0, dy: secondShift)
                }) { _ in
                    UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseIn, animations: {
                        let secondShift = self.height * self.chatViewSecondShift / self.ethalonHeight
                        self.chatView.frame = self.chatView.frame.offsetBy(dx: 0, dy: secondShift)
                    }) { _ in
                        UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseIn, animations: {
                            let secondShift = self.height * self.chatViewSecondShift / self.ethalonHeight
                            self.chatView.frame = self.chatView.frame.offsetBy(dx: 0, dy: secondShift)
                        }) { _ in
                            if self.indicator.currentPage == 4 {
                                if !self.button.isUserInteractionEnabled {
                                    self.button.removeTarget(self, action: #selector(self.satoshiAction), for: .touchUpInside)
                                    self.button.addTarget(self, action: #selector(self.spvAction), for: .touchUpInside)
                                    self.button.isUserInteractionEnabled = true
                                    self.button.alpha = 1
                                }
                                UIView.animate(withDuration: 0.2, delay: 2.5, options: .curveEaseInOut, animations: {
                                    self.chatView.alpha = 0
                                }) { _ in
                                    self.chatView.frame = self.adoptedFrame(frame: self.chatViewFrame)
                                    UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
                                        self.chatView.alpha = 1
                                    }) { _ in
                                        self.satoshiAnimationCycle()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func removeSatoshiAnimations() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 0
            self.satLabel.alpha = 0
            self.phoneScreen.alpha = 0
        }) { _ in
            self.chatView.removeFromSuperview()
            self.satBar.removeFromSuperview()
            self.satLabel.removeFromSuperview()
        }
    }
    
    //MARK: SPV
    private func spvAnimation() {
        titleLabel.text = LocalizedStrings.titleSpv
        spvLabel = UILabel(frame: adoptedFrame(frame: spvLabelFrame))
        if Layout.model == .ten {
            spvLabel.frame = spvLabel.frame.offsetBy(dx: -10, dy: 60)
        }
        setupLabel(label: spvLabel)
        spvLabel.text = LocalizedStrings.spvLabel
        spvLabel.alpha = 0
        view.addSubview(spvLabel)
        
        prepareForSpv()
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveEaseInOut, animations: {
            self.titleLabel.alpha = 1
            self.spvLabel.alpha = 1
            self.phoneScreen.alpha = 1
        }) { _ in
            self.spvAnimationCycle()
        }
    }
    
    private func spvAnimationCycle() {
        let adoptedProgressFrame = adoptedFrame(frame: spvProgressFrame)
        
        progressInc()
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.spvProgressView.frame = self.spvBalanceView.bounds
        }) { _ in
            //
        }
        
        if !self.button.isUserInteractionEnabled {
            self.button.removeTarget(self, action: #selector(self.spvAction), for: .touchUpInside)
            self.button.addTarget(self, action: #selector(self.gotoCreate), for: .touchUpInside)
            self.button.isUserInteractionEnabled = true
            self.button.alpha = 1
        }
        UIView.animate(withDuration: 0.2, delay: 2.1, options: .curveEaseInOut, animations: {
            self.spvProgressLabel.alpha = 0
            self.spvProgressView.alpha = 0
            self.spvBalanceStatic.alpha = 1
            self.spvBalanceView.alpha = 0
        }) { _ in
            self.spvProgressLabel.text = "0 %"
            self.spvProgressView.frame = adoptedProgressFrame
            UIView.animate(withDuration: 0.2, delay: 2.0, options: .curveEaseInOut, animations: {
                self.spvProgressLabel.alpha = 1
                self.spvProgressView.alpha = 1
                self.spvBalanceStatic.alpha = 0
                self.spvBalanceView.alpha = 1
            }) { _ in
                self.spvAnimationCycle()
            }
        }
    }
    
    @objc private func progressInc() {
        if spvProgressLabel.text != "100 %" {
            guard let progressStr = spvProgressLabel.text?.components(separatedBy: " ").first else { return }
            guard let progress = Int(progressStr) else { return }
            spvProgressLabel.text = "\(progress+1) %"
            self.perform(#selector(progressInc), with: nil, afterDelay: 0.0145)
        }
    }
    
    private func prepareForSpv() {
        spvBackView = UIImageView(frame: phoneScreen.bounds)
        spvBackView.image = spvBackImage
        phoneScreen.addSubview(spvBackView)
        
        spvBalanceView = UIView(frame: adoptedFrame(frame: spvBalanceFrame))
        spvBalanceView.backgroundColor = Color.defaultGray.withAlphaComponent(0.5)
        spvBalanceView.layer.cornerRadius = Layout.model.cornerRadius * 306 / 414
        spvBalanceView.layer.masksToBounds = true
        phoneScreen.addSubview(spvBalanceView)
        
        spvProgressView = UIView(frame: adoptedFrame(frame: spvProgressFrame))
        spvProgressView.backgroundColor = Color.defaultGray
        spvBalanceView.addSubview(spvProgressView)
        
        let adoptedIndicatorFrame = adoptedFrame(frame: spvIndicatorFrame)
        spvIndicatorView = UIActivityIndicatorView(frame: adoptedIndicatorFrame)
        spvIndicatorView.activityIndicatorViewStyle = .white
        spvIndicatorView.startAnimating()
        let factor = adoptedIndicatorFrame.width / 20
        spvIndicatorView.transform = CGAffineTransform(scaleX: factor, y: factor)
        spvBalanceView.addSubview(spvIndicatorView)
        
        spvTopLabel = UILabel(frame: adoptedFrame(frame: spvTopLabelFrame))
        setupLabel(label: spvTopLabel)
        spvTopLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        spvTopLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        spvTopLabel.text = LocalizedStrings.spvTopLabel
        spvBalanceView.addSubview(spvTopLabel)
        
        spvProgressLabel = UILabel(frame: adoptedFrame(frame: spvProgressLabelFrame))
        setupLabel(label: spvProgressLabel)
        spvProgressLabel.text = "0 %"
        spvBalanceView.addSubview(spvProgressLabel)

        
        spvBottomLabel = UILabel(frame: adoptedFrame(frame: spvBottomLabelFrame))
        setupLabel(label: spvBottomLabel)
        spvBottomLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        spvBottomLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        spvBottomLabel.text = LocalizedStrings.spvBottomLabel
        spvBalanceView.addSubview(spvBottomLabel)
        
        spvBalanceStatic = UIImageView(frame: adoptedFrame(frame: spvBalanceFrame))
        if Locale.current.identifier.split(separator: "_").first == "ru" {
            spvBalanceStaticImage = UIImage(named: "BalanceStaticRu")
        }
        spvBalanceStatic.image = spvBalanceStaticImage
        phoneScreen.addSubview(spvBalanceStatic)
        spvBalanceStatic.alpha = 0
    }
    
    //MARK: End flyoff
    private func flyoffAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.spvLabel.alpha = 0
            self.titleLabel.alpha = 0
            self.indicator.alpha = 0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.phone.frame = self.phone.frame.offsetBy(dx: 0, dy: -self.height)
                self.phoneScreen.frame = self.phoneScreen.frame.offsetBy(dx: 0, dy: -self.height)
                self.button.frame = self.button.frame.offsetBy(dx: 0, dy: Layout.model.height + Layout.model.offset)
            }) { _ in
                self.router?.showAddWalletView()
            }
        }
    }
    
    //MARK: Actions
    @objc private func airAction() {
        indicator.currentPage = 1
        button.isUserInteractionEnabled = false
        button.alpha = 0
        prepareForAirConnectivity()
        airConnectivityAnimation()
    }
    
    @objc private func receiveAction() {
        indicator.currentPage = 2
        button.isUserInteractionEnabled = false
        button.alpha = 0
        receiveAnimation()
    }
    
    @objc private func feeAction() {
        indicator.currentPage = 3
        button.isUserInteractionEnabled = false
        button.alpha = 0
        removeReceiveAnimations()
        feeAnimation()
    }
    
    @objc private func satoshiAction() {
        indicator.currentPage = 4
        button.isUserInteractionEnabled = false
        button.alpha = 0
        removeFeeAnimations { [unowned self] () in
            self.satoshiAnimation()
        }
    }
    
    @objc private func spvAction() {
        indicator.currentPage = 5
        button.isUserInteractionEnabled = false
        button.alpha = 0
        removeSatoshiAnimations()
        spvAnimation()
    }
    
    @objc private func gotoCreate() {
        button.isUserInteractionEnabled = false
        button.alpha = 0
        flyoffAnimation()
    }
}

extension AboutViewController: AboutVMDelegate {
    func didFinishAbout() {}
}
