//
//  CustomLayoutAttributes.swift
//  Gifer
//
//  Created by Mikhalkov, Eugene on 10/5/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import UIKit

class CustomLayoutAttributes: UICollectionViewLayoutAttributes {

    var gifHeight = 0.0
    var gifWidth = 0.0

    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! CustomLayoutAttributes
        copy.gifHeight = gifHeight
        copy.gifWidth = gifWidth
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? CustomLayoutAttributes {
            if(attributes.gifHeight == gifHeight && attributes.gifWidth == gifWidth) {
                return super.isEqual(object)
            }
        }
        return false
    }

}
