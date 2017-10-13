
import UIKit

class CustomLayoutAttributes: UICollectionViewLayoutAttributes {

    public var gifHeight = 0.0
    public var gifWidth = 0.0

    override func copy(with zone: NSZone?) -> Any {
        super.copy(with: zone)
        let copy = super.copy(with: zone) as! CustomLayoutAttributes
        copy.gifHeight = gifHeight
        copy.gifWidth = gifWidth
        return copy
    }
}
