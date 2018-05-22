//
//  ShopLayout.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ShopLayout: UICollectionViewLayout {

    private let heights: [CGFloat] = [140, 140, 140, 140, 62, 280, 220]
    private let widthProps: [CGFloat] = [0.6, 0.4, 0.4, 0.6, 0.6, 0.4, 0.6]
    
    private var numberOfColumns = 2
    private var cellPadding: CGFloat = Layout.model.spacing/2
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else {
            return
        }
        
        var xOffsets = [CGFloat]()
        for i in 0...heights.count-1 {
            var x: CGFloat = 0
            if !(i % 2 == 0) {
                x = contentWidth * widthProps[(i-1) % heights.count]
            }
            xOffsets.append(x)
        }
        
        var yOffset: CGFloat = 0

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let variant = item % heights.count
            let height = heights[variant]
            let width = contentWidth * widthProps[variant]
            let x = xOffsets[variant]
            
            let frame = CGRect(x: x, y: yOffset, width: width, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            
            if variant == heights.count-1 {
                yOffset = yOffset + heights[variant]
            } else if variant % 2 != 0  {
                yOffset = yOffset + heights[variant-1]
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

}
