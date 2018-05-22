//
//  ContactsFlowLayout.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 19/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ContactsFlowLayout: UICollectionViewFlowLayout {
    
    func initialize() {
        self.scrollDirection = .vertical
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let verticalOffset = proposedContentOffset.y
        let targetRect = CGRect(origin: CGPoint(x: 0, y: proposedContentOffset.y), size: self.collectionView!.bounds.size)
        
        for layoutAttributes in super.layoutAttributesForElements(in: targetRect)! {
            let itemOffset = layoutAttributes.frame.origin.y
            if (abs(itemOffset - verticalOffset) < abs(offsetAdjustment)) {
                offsetAdjustment = itemOffset - verticalOffset
            }
        }
        
        return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y + offsetAdjustment)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesArray  = super.layoutAttributesForElements(in: rect)
        
        attributesArray?.forEach({ (attributes) in
            var length: CGFloat = 0
            var contentOffset: CGFloat = 0
            var position: CGFloat = 0
            let collectionView = self.collectionView!
            
            if (self.scrollDirection == .horizontal) {
                length = attributes.size.width
                contentOffset = collectionView.contentOffset.x
                position = attributes.center.x - attributes.size.width / 2
            } else {
                length = attributes.size.height
                contentOffset = collectionView.contentOffset.y
                position = attributes.center.y - attributes.size.height / 2
            }
            
            if (position >= 0 && position <= contentOffset) {
                let differ: CGFloat = contentOffset - position
                let alphaFactor: CGFloat =  1 - differ / length
                attributes.alpha = alphaFactor
                attributes.transform3D = CATransform3DMakeTranslation(0, differ, 0)
            } else if (position - contentOffset > collectionView.frame.height - Layout.model.height - Layout.model.spacing && position - contentOffset <= collectionView.frame.height) {
                let differ: CGFloat = collectionView.frame.height - position + contentOffset
                let alphaFactor: CGFloat =  differ / length
                attributes.alpha = alphaFactor
                attributes.transform3D = CATransform3DMakeTranslation(0, differ - length, 0)
                attributes.zIndex = -1
            } else {
                attributes.alpha = 1
                attributes.transform = CGAffineTransform.identity
            }
        })
        
        return attributesArray
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
