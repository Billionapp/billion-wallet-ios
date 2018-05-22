//
//  GeneralFlowLayout.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GeneralFlowLayout: UICollectionViewFlowLayout {
    
    func initialize() {
        self.sectionInset = UIEdgeInsetsMake(0, Layout.model.offset, 0, Layout.model.offset)
        self.scrollDirection = .vertical
        self.minimumLineSpacing = Layout.model.spacing
        self.itemSize = CGSize(width: UIScreen.main.bounds.width - Layout.model.offset * 2, height: Layout.model.height)
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
                offsetAdjustment = itemOffset - verticalOffset - Layout.model.offset / 2
            }
        }

        return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y + offsetAdjustment)
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
//        TODO: Customize item appearing
//        if (collectionView?.numberOfItems(inSection: 0)) == itemIndexPath.row {
//            attributes?.transform3D = CATransform3DMakeScale(0, 0, 0)
//            attributes?.alpha = 0
//        }
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        for attribute in attributes! {
            attribute.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }
        return attributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        attributes?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        return attributes
    }

}
