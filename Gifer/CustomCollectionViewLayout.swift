//
//  CustomCollectionViewLayout.swift
//  Gifer
//
//  Created by Niar on 9/28/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation
import UIKit

protocol CustomCollectionViewLayoutDelegate {
    func collectionView(_ collectionView:UICollectionView, heightForGifAtIndexPath indexPath:IndexPath, fixedWidth:CGFloat) -> CGFloat
}



class CustomCollectionViewLayout: UICollectionViewLayout {
    
    var delegate: CustomCollectionViewLayoutDelegate!
    fileprivate var attributes = [CustomLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0.0
    fileprivate var contentWidth: CGFloat = 0.0
    
    override class var layoutAttributesClass : AnyClass {
        return CustomLayoutAttributes.self
    }
    
    override func prepare() {
        
        var column = 0
        contentHeight = 0
        contentWidth = collectionView!.frame.width - collectionView!.contentInset.left - collectionView!.contentInset.right
        let itemWidth: CGFloat = floor(contentWidth / 2.0)
        let xOffset: [CGFloat] = [0, itemWidth]
        var yOffset: [CGFloat] = [0, 0]
        attributes = []
        
        for item in 0..<collectionView!.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            let gifWidth = itemWidth - 2 * Constants.cellPadding
            let gifHeight = delegate.collectionView(collectionView!, heightForGifAtIndexPath: indexPath, fixedWidth: gifWidth)
            let itemHeight = gifHeight + 2 * Constants.cellPadding
            
            if yOffset[0] > yOffset[1] {
                column = 1
            } else {
                column = 0
            }
            
            let itemFrame = CGRect(x: xOffset[column], y: yOffset[column], width: itemWidth, height: itemHeight)
            let attribute = CustomLayoutAttributes(forCellWith: indexPath)
            attribute.frame = itemFrame
            attribute.gifHeight = gifHeight
            attribute.gifWidth = gifWidth
            attributes.append(attribute)
            
            contentHeight = max(contentHeight, itemFrame.maxY)
            yOffset[column] = yOffset[column] + itemHeight
            
        }
        
    }
    
    override var collectionViewContentSize : CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in attributes {
            if attribute.frame.intersects(rect) {
                layoutAttributes.append(attribute)
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
    
}
