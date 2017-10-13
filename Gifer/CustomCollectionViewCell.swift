
import UIKit
import SDWebImage

class CustomCollectionViewCell: UICollectionViewCell {

    private var imageView: FLAnimatedImageView = FLAnimatedImageView()

    private let cellPaddingLeft: CGFloat = 5.0
    private let cellPaddingRight: CGFloat = 5.0
    private let cellPaddingTop: CGFloat = 5.0
    private let cellPaddingBottom: CGFloat = 5.0

    public var gif: GifModel? {
        didSet {
            if let gif = gif, let url = gif.url {
                imageView.sd_setImage(with: URL(string: url))
            }
            if let gif = gif, let trended = gif.trended, trended == true {
                trendedImageView = UIImageView(image: UIImage(named: Constants.trendedIconName))
            }
        }
    }

    private var trendedImageView: UIImageView = UIImageView() {
        didSet {
            trendedImageView.frame = CGRect(x: cellPaddingTop * 2,
                                            y: cellPaddingRight * 2,
                                            width: Constants.trendedIconSize,
                                            height: Constants.trendedIconSize)
            self.addSubview(trendedImageView)
        }
    }
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? CustomLayoutAttributes else { return }
        imageView.backgroundColor = .gray
        self.addSubview(imageView)
        imageView.frame = CGRect(x: cellPaddingTop,
                                 y: cellPaddingRight,
                                 width: CGFloat(attributes.gifWidth),
                                 height: CGFloat(attributes.gifHeight))
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.animatedImage = nil
        trendedImageView.removeFromSuperview()
        trendedImageView = UIImageView()
    }
}
