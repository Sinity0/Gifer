import UIKit

protocol GiferLayoutDelegate: class {
    func heightOfElement(heightForGifAtIndexPath indexPath: IndexPath, fixedWidth: CGFloat) -> CGFloat
}

class GiferLayout: UICollectionViewLayout {

    weak var delegate: GiferLayoutDelegate?

    private var numberOfColumns = 2
    private var cellPadding: CGFloat = 6.0
    private var cache: [CustomLayoutAttributes] = []
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override class var layoutAttributesClass: AnyClass {
        return CustomLayoutAttributes.self
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []

        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }

        var column = 0
        var yOffset: [CGFloat] = Array<CGFloat>(repeating: 0, count: numberOfColumns)

        let itemWidth: CGFloat = floor(contentWidth / 2.0)
        cache.removeAll()

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {

            let indexPath = IndexPath(item: item, section: 0)

            guard let gifHeight = delegate?.heightOfElement(heightForGifAtIndexPath: indexPath, fixedWidth: CGFloat(itemWidth)) else { return }
            let height = cellPadding * 2 + gifHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = CustomLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            attributes.gifHeight = gifHeight
            attributes.gifWidth = itemWidth - cellPadding * 2

            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        if let superAttr = super.layoutAttributesForElements(in: rect) {
            visibleLayoutAttributes += superAttr
        }

        visibleLayoutAttributes = cache.filter { $0.frame.intersects(rect) }

        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
