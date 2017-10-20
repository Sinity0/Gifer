import UIKit
import SDWebImage

class CustomCollectionViewCell: UICollectionViewCell {
    
    private var imageView: FLAnimatedImageView = FLAnimatedImageView()
    
    public var gif: GifModel? {
        didSet {
            guard let gif = gif, let url = gif.url else { return }
            imageView.sd_setImage(with: URL(string: url))
            guard let trended = gif.trended, trended else { return }
            trendedImageView = UIImageView(image: UIImage(named: Constants.trendedIconName))
        }
    }

    private var trendedImageView: UIImageView = UIImageView() {
        didSet {

            trendedImageView.frame = CGRect(x: Constants.cellInsets.left * 2,
                                            y: Constants.cellInsets.top * 2,
                                            width: Constants.trendedIconSize,
                                            height: Constants.trendedIconSize)
            addSubview(trendedImageView)
        }
    }
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes) 
        guard let attributes = layoutAttributes as? CustomLayoutAttributes else { return }
        imageView.backgroundColor = .gray
        addSubview(imageView)
        imageView.frame = CGRect(x: Constants.cellInsets.left,
                                 y: Constants.cellInsets.top,
                                 width: CGFloat(attributes.gifWidth),
                                 height: CGFloat(attributes.gifHeight))
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.animatedImage = nil
        trendedImageView.removeFromSuperview()
    }
}
