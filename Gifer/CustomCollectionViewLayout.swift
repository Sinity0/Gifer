
import UIKit

protocol CustomCollectionViewLayoutDelegate {
    func collectionView(_ collectionView:UICollectionView, heightForGifAtIndexPath indexPath:IndexPath, fixedWidth:Double) -> Double
}

class CustomCollectionViewLayout: UICollectionViewLayout {
    
    var delegate: CustomCollectionViewLayoutDelegate!
    private var attributes = [CustomLayoutAttributes]()
    private var contentHeight: Double = 0.0
    private var contentWidth: Double = 0.0
    
    override class var layoutAttributesClass : AnyClass {
        return CustomLayoutAttributes.self
    }
    
    override func prepare() {
        
        var column = 0
        contentHeight = 0
        contentWidth = Double(collectionView!.frame.width - collectionView!.contentInset.left - collectionView!.contentInset.right)
        let itemWidth: Double = floor(contentWidth / 2.0)
        let xOffset: [Double] = [0, itemWidth]
        var yOffset: [Double] = [0, 0]
        attributes = []
        
        for item in 0..<collectionView!.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            let gifWidth: Double = itemWidth - 2 * Double(Constants.cellPaddingRight)
            let gifHeight: Double = delegate.collectionView(collectionView!, heightForGifAtIndexPath: indexPath, fixedWidth: gifWidth)
            let itemHeight: Double = gifHeight + 2 * Double(Constants.cellPaddingTop)
            
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
            
            contentHeight = max(contentHeight, Double(itemFrame.maxY))
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
