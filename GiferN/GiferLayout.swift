
import UIKit

protocol GiferLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, heightForGifAtIndexPath indexPath: IndexPath, fixedWidth: CGFloat) -> CGFloat
}

class GiferLayout: UICollectionViewLayout {

    weak var delegate: GiferLayoutDelegate!

    fileprivate var numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 6
    fileprivate var cache = [CustomLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0

    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override class var layoutAttributesClass : AnyClass {
        return CustomLayoutAttributes.self
    }

    override func prepare() {
//        super.prepare() //Void
        guard let collectionView = collectionView else {
            return
        }

        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        let itemWidth: Double = floor(Double(contentWidth) / 2.0)
        cache = []

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {

            let indexPath = IndexPath(item: item, section: 0)

            let gifHeight = delegate.collectionView(collectionView, heightForGifAtIndexPath: indexPath, fixedWidth: CGFloat(itemWidth))
            let height = cellPadding * 2 + gifHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = CustomLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            attributes.gifHeight = Double(gifHeight)
            attributes.gifWidth = itemWidth - 15

            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }

    // FIXME: do i need super??
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        //let superAttr = super.layoutAttributesForElements(in: rect)
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

//        if let superAttr = super.layoutAttributesForElements(in: rect) {
//            visibleLayoutAttributes += superAttr
//        }

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
