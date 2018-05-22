//
//  TransactionCollectionCell.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol TxCellDelegate: class {
    func bubbleButtonPressed(_ sender: TxCell)
}

class TxCell: UICollectionViewCell {
    
    typealias LocalizedStrings = Strings.General
    
    weak var delegate: TxCellDelegate?
    var identity: String = ""
    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainCurrencyLabel: UILabel!
    @IBOutlet weak var btcLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var interactionImageView: UIImageView!
    @IBOutlet weak var touchView: TouchView!
    
    private var previewInteraction: UIPreviewInteraction!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        previewInteraction = UIPreviewInteraction(view: touchView)
        previewInteraction.delegate = self
        touchView.setDelegate(self)
    }
}

// MARK: - Configure

extension TxCell {
    func configure(with transaction: HistoryDisplayable, fiatConverter: FiatConverter) {
        let resizeInsets = UIEdgeInsetsMake(24, 24, 24, 24)
        let bubbleImage = transaction.bubbleImage.resizableImage(withCapInsets: resizeInsets, resizingMode: .stretch)
        self.identity = transaction.identity
        
        bubbleImageView.image = bubbleImage
        titleLabel.text = transaction.header
        mainCurrencyLabel.text = transaction.title
        btcLabel.text = transaction.subtitle
        
        switch transaction.interaction {
        case .timestamp(let time):
            timeLabel.text = time
            timeLabel.isHidden = false
            interactionImageView.isHidden = true
        case .interaction(let icon):
            interactionImageView.image = icon
            timeLabel.isHidden = true
            interactionImageView.isHidden = false
        }
    }
}

extension TxCell: TouchViewDelegate {
    func touchEnded() {
        // TODO: pass identity instead of full self
        delegate?.bubbleButtonPressed(self)
    }
}

extension TxCell: UIPreviewInteractionDelegate {
    func previewInteractionShouldBegin(_ previewInteraction: UIPreviewInteraction) -> Bool {
        return previewInteraction.view == self.touchView
    }
    
    func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdatePreviewTransition transitionProgress: CGFloat, ended: Bool) {
        
        let scrollView = self.superview as! UICollectionView
        let gesture = scrollView.panGestureRecognizer
        guard gesture.state == UIGestureRecognizerState.possible else {
                return
        }
        
        guard let bubbleView = previewInteraction.view else {
            previewInteraction.cancel()
            return
        }
        let gridStep = Layout.model.spacing
        let bubbleOffset = CGFloat(5.0)
        let touchBump = CGFloat(1.04)
        let w = (bubbleView.frame.width - bubbleOffset)
        let normalizedProgress = transitionProgress * ( gridStep / w ) + touchBump
        
        if ended {
            UIView.animate(withDuration: 0.1, animations: {
                bubbleView.subviews.forEach { (subview) in
                    subview.transform = CGAffineTransform(scaleX: normalizedProgress, y: normalizedProgress)
                }
            }, completion: { _ in
                self.delegate?.bubbleButtonPressed(self)
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
}

