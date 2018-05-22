//
//  OnboardViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 19/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class OnboardViewController: BaseViewController<OnboardVM> {
    
    weak var router: MainRouter?
    
    typealias LocalizedStrings = Strings.Onboarding
    
    let height = UIScreen.main.bounds.height
    let width = UIScreen.main.bounds.width
    let screenRect = UIScreen.main.bounds
    let sizeOfLabels = CGFloat(74)
    var countOfCharsByWidth:CGFloat {
        switch Locale.current.identifier.split(separator: "_").first {
            case "ru":
                return sizeOfLabels/12
            default:
                return sizeOfLabels/6
        }
    }
    let ethalonWidth = CGFloat(414)
    let ethalonHeight = CGFloat(736)
    let horizonInset = CGFloat(10)
    
    private let cubeFirstLineFrame = CGRect(x: 47, y: 216, width: 320, height: 40)
    private let cubeSecondLineFrame = CGRect(x: 47, y: 256, width: 320, height: 55)
    private var cubeThirdLineFrame = CGRect(x: 47, y: 311, width: 320, height: 65)
    private let cubeFourthLineFrame = CGRect(x: 47, y: 376, width: 320, height: 70)
    
    override func configure(viewModel: OnboardVM) {
        super.configure(viewModel: viewModel)
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.flushOldDataIfRestored()
        animateWordSequense()
    }
    
    private func labelDecorate(label: UILabel) {
        label.font = UIFont.systemFont(ofSize: sizeOfLabels, weight: .bold)
        label.textColor = Color.Onboard.labelColor
        label.alpha = 0
        self.view.addSubview(label)
    }
 
    private func animateWordSequense() {
        
        let maxSymbols = max(CGFloat(LocalizedStrings.impleWord.count), CGFloat(LocalizedStrings.ecureWord.count), CGFloat(LocalizedStrings.ocialWord.count))
        let w = UIScreen.main.bounds.width / countOfCharsByWidth
        let dividedChars = (countOfCharsByWidth - maxSymbols + 0.5) / 2
        let dividedX = dividedChars * w
        
        
        //IS
        let isLabel = UILabel(frame: screenRect)
        isLabel.text = LocalizedStrings.isWord
        isLabel.textAlignment = .center
        labelDecorate(label: isLabel)
        //S
        let sLabel = UILabel(frame: screenRect)
        sLabel.frame.size.width = dividedX
        sLabel.text = LocalizedStrings.sWord
        sLabel.textAlignment = .right
        labelDecorate(label: sLabel)
        //IMPLE
        let impleLabel = UILabel(frame: screenRect)
        switch Locale.current.identifier.split(separator: "_").first {
            case "ru":
                impleLabel.frame.origin.x = horizonInset
                impleLabel.adjustsFontSizeToFitWidth = true
                impleLabel.lineBreakMode = .byClipping
                impleLabel.frame.size.width = screenRect.size.width - horizonInset * 2
                impleLabel.textAlignment = .center
            default:
                impleLabel.frame.origin.x = dividedX
                impleLabel.textAlignment = .left
        }
        impleLabel.text = LocalizedStrings.impleWord
        labelDecorate(label: impleLabel)
        //ECURE
        let ecureLabel = UILabel(frame: screenRect)
        switch Locale.current.identifier.split(separator: "_").first {
            case "ru":
                ecureLabel.frame.origin.x = horizonInset
                ecureLabel.adjustsFontSizeToFitWidth = true
                ecureLabel.lineBreakMode = .byClipping
                ecureLabel.frame.size.width = screenRect.size.width - horizonInset * 2
                ecureLabel.textAlignment = .center
            default:
                ecureLabel.frame.origin.x = dividedX
                ecureLabel.textAlignment = .left
        }
        ecureLabel.frame.origin.y = ecureLabel.frame.origin.y + Layout.model.height
        ecureLabel.text = LocalizedStrings.ecureWord
        labelDecorate(label: ecureLabel)
        //OCIAL
        let ocialLabel = UILabel(frame: screenRect)
        switch Locale.current.identifier.split(separator: "_").first {
            case "ru":
                ocialLabel.frame.origin.x = horizonInset
                ocialLabel.adjustsFontSizeToFitWidth = true
                ocialLabel.lineBreakMode = .byClipping
                ocialLabel.frame.size.width = screenRect.size.width - horizonInset * 2
                ocialLabel.textAlignment = .center
            default:
                ocialLabel.frame.origin.x = dividedX
                ocialLabel.textAlignment = .left
        }
        ocialLabel.frame.origin.y = ocialLabel.frame.origin.y + Layout.model.height
        ocialLabel.text = LocalizedStrings.ocialWord
        labelDecorate(label: ocialLabel)
        //WALLET
        let walletLabel = UILabel(frame: screenRect)
        walletLabel.text = LocalizedStrings.walletWord
        walletLabel.textAlignment = .center
        labelDecorate(label: walletLabel)
        if Locale.current.identifier.split(separator: "_").first == "ru" {
            walletLabel.adjustsFontSizeToFitWidth = true
            walletLabel.frame.origin.x = horizonInset
            walletLabel.frame.size.width = screenRect.size.width - horizonInset * 2
        }
        walletLabel.font = UIFont.systemFont(ofSize: sizeOfLabels + 30, weight: .bold)
        
        UIView.animate(withDuration: 1.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
            isLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3,
                           delay: 0.8,
                           options: .curveEaseInOut,
                           animations: {
                isLabel.alpha = 0
            }, completion: nil)
            UIView.animate(withDuration: 0.3,
                           delay: 0.9,
                           options: .curveEaseInOut,
                           animations: {
                sLabel.alpha = 1
                impleLabel.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.4,
                               delay: 0.5,
                               options: .curveEaseInOut,
                               animations: {
                    impleLabel.alpha = 0
                    impleLabel.frame.origin.y = impleLabel.frame.origin.y - Layout.model.height
                    ecureLabel.alpha = 1
                    ecureLabel.frame.origin.y = ecureLabel.frame.origin.y - Layout.model.height
                }) { _ in
                    UIView.animate(withDuration: 0.4,
                                   delay: 0.5,
                                   options: .curveEaseInOut,
                                   animations: {
                        ecureLabel.alpha = 0
                        ecureLabel.frame.origin.y = ecureLabel.frame.origin.y - Layout.model.height
                        ocialLabel.alpha = 1
                        ocialLabel.frame.origin.y = ocialLabel.frame.origin.y - Layout.model.height
                    }) { _ in
                        UIView.animate(withDuration: 0.1,
                                       delay: 0.69,
                                       options: .curveEaseInOut,
                                       animations: {
                            ocialLabel.alpha = 0
                            sLabel.alpha = 0
                        })
                        UIView.animate(withDuration: 0.3,
                                       delay: 0.7,
                                       options: .curveEaseInOut,
                                       animations: {
                            walletLabel.alpha = 1
                        }) { _ in
                            UIView.animate(withDuration: 0.3,
                                           delay: 1.7,
                                           options: .curveEaseInOut,
                                           animations: {
                                            walletLabel.alpha = 0
                            }) { _ in
                                self.view.subviews.forEach({ $0.removeFromSuperview() })
                                self.animateCubeSequence()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func animateCubeSequence() {
        // English phrase: "This wallet gives you an entirely New experiennce of Bitcoin"
        
        let thisRect = adjustRect(rect: cubeFirstLineFrame)
        let thisRectShifted = thisRect.offsetBy(dx: 0, dy: UIScreen.main.bounds.height - thisRect.origin.y)
        let thisLabel = createCubeLabel(rect: thisRectShifted, fontSize: 28, text: LocalizedStrings.thisWalletGivesYou, alignment: .center)
        view.addSubview(thisLabel)
        
        let anEntirelyRect = adjustRect(rect: cubeSecondLineFrame)
        let anEntirelyRectShifted = anEntirelyRect.offsetBy(dx: 0, dy: UIScreen.main.bounds.height - anEntirelyRect.origin.y)
        let anEntirelyLabel = createCubeLabel(rect: anEntirelyRectShifted, fontSize: 38, text: LocalizedStrings.anEntirelyNew, alignment: .center)
        view.addSubview(anEntirelyLabel)
        
        if Locale.current.identifier.split(separator: "_").first == "ru" {
            cubeThirdLineFrame.origin.y = CGFloat(306)
        }
        let expRect = adjustRect(rect: cubeThirdLineFrame)
        let expRectShifted = expRect.offsetBy(dx: 0, dy: UIScreen.main.bounds.height - expRect.origin.y)
        let expLabel = createCubeLabel(rect: expRectShifted, fontSize: 48, text: LocalizedStrings.experienceWord, alignment: .center)
        view.addSubview(expLabel)
        
        let ofBitcoinRect = adjustRect(rect: cubeFourthLineFrame)
        let ofBitcoinLabel = createCubeLabel(rect: ofBitcoinRect, fontSize: 70, text: LocalizedStrings.ofBitcoinWord, alignment: .center)
        ofBitcoinLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        view.addSubview(ofBitcoinLabel)
        
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                    thisLabel.alpha = 1
                    thisLabel.frame = thisRect
        }) { _ in
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                        anEntirelyLabel.alpha = 1
                        anEntirelyLabel.frame = anEntirelyRect
            }) { _ in
                UIView.animate(withDuration: 0.5,
                               delay: 0.0,
                               options: .curveEaseInOut,
                               animations: {
                            expLabel.alpha = 1
                            expLabel.frame = expRect
                }) { _ in
                    UIView.animate(withDuration: 0.8,
                                   delay: 0.0,
                                   options: .curveEaseInOut,
                                   animations: {
                                ofBitcoinLabel.alpha = 1
                                ofBitcoinLabel.transform = CGAffineTransform.identity
                    }) { _ in
                        UIView.animate(withDuration: 0.4,
                                       delay: 1.8,
                                       options: .curveEaseInOut,
                                       animations: {
                                        self.view.alpha = 0
                        }) { _ in
                            self.router?.showAbout()
                        }
                    }
                }
            }
        }
    }
    
    private func adjustRect(rect: CGRect) -> CGRect {
        return CGRect(x: width * rect.origin.x / ethalonWidth,
                      y: height * rect.origin.y / ethalonHeight,
                      width: width * rect.size.width / ethalonWidth,
                      height: height * rect.size.height / ethalonHeight)
    }
    
    private func createCubeLabel(rect: CGRect, fontSize: CGFloat, text: String, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel(frame: rect)
        label.font = UIFont.systemFont(ofSize: fontSize * width / ethalonWidth,
                                       weight: .bold)
        label.text = text
        label.textAlignment = alignment
        label.textColor = Color.Onboard.labelColor
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.alpha = 0
        return label
    }
}

//MARK: OnboardVMDelegate
extension OnboardViewController: OnboardVMDelegate {
    func didFinishOnboarding() {
        self.router?.showStartScreen()
    }
}
