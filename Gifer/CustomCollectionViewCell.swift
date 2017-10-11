//
//  CustomCollectionViewCell.swift
//  Gifer
//
//  Created by Niar on 9/28/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import UIKit
import SDWebImage

class CustomCollectionViewCell: UICollectionViewCell {

    var imageView: FLAnimatedImageView?

    var gif: GifModel? {
        didSet {
            if let gif = gif, let url = gif.url {
                imageView?.sd_setImage(with: URL(string: url))
            }
            if let gif = gif, let trended = gif.trended, trended == true {
                trendedImageView = UIImageView(image: UIImage(named: Constants.trendedIconName))
            }
        }
    }

    var trendedImageView: UIImageView? {
        didSet {
            if let trendedImageView = trendedImageView {
                trendedImageView.frame = CGRect(x: Constants.cellPaddingTop * 2,
                                                y: Constants.cellPaddingRight * 2,
                                                width: Constants.trendedIconSize,
                                                height: Constants.trendedIconSize)
                self.addSubview(trendedImageView)
            }
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? CustomLayoutAttributes {
            if imageView == nil {
                imageView = FLAnimatedImageView()
                imageView?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
                
                self.addSubview(imageView!)
            }
            imageView?.frame = CGRect(x: Constants.cellPaddingTop,
                                      y: Constants.cellPaddingRight,
                                      width: CGFloat(attributes.gifWidth),
                                      height: CGFloat(attributes.gifHeight))
            imageView?.layer.cornerRadius = 16
            imageView?.layer.masksToBounds = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if imageView != nil {
            imageView?.animatedImage = nil
        }
        if trendedImageView != nil {
            trendedImageView?.removeFromSuperview()
            trendedImageView = nil
        }
    }
}
