//
//  CustomCollectionViewCell.swift
//  Gifer
//
//  Created by Niar on 9/28/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class CustomCollectionViewCell: UICollectionViewCell {
    
    var gif: GifsModel? {
        didSet {
            if let gif = gif, let url = gif.url {
                imageView.sd_setImage(with: URL.init(string: url))
            }
            if let gif = gif, let trended = gif.trended, trended == true {
                trendedImageView = UIImageView.init(image: UIImage.init(named: Constants.trendedIconName))
            }
        }
    }
    
    var imageView: FLAnimatedImageView!
    var trendedImageView: UIImageView? {
        didSet {
            if let trendedImageView = trendedImageView {
                trendedImageView.frame = CGRect(x: Constants.cellPadding * 2, y: Constants.cellPadding * 2, width: Constants.trendedIconSize, height: Constants.trendedIconSize)
                self.addSubview(trendedImageView)
            }
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? CustomLayoutAttributes {
            if imageView == nil {
                imageView = FLAnimatedImageView()
                imageView.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
                
                self.addSubview(imageView)
            }
            imageView.frame = CGRect(x: Constants.cellPadding, y: Constants.cellPadding, width: attributes.gifWidth, height: attributes.gifHeight)
            imageView.layer.cornerRadius = 16
            imageView.layer.masksToBounds = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if imageView != nil {
            imageView.animatedImage = nil
        }
        if trendedImageView != nil {
            trendedImageView?.removeFromSuperview()
            trendedImageView = nil
        }
    }
}
