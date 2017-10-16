
import UIKit
import SDWebImage

class CustomCollectionViewCell: UICollectionViewCell {
    
    private var imageView: FLAnimatedImageView = FLAnimatedImageView()
    
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
            trendedImageView.frame = Constants.trendedImageframe
            self.addSubview(trendedImageView)
        }
    }
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        //super.apply(layoutAttributes) //Void
        guard let attributes = layoutAttributes as? CustomLayoutAttributes else { return }
        imageView.backgroundColor = .gray
        self.addSubview(imageView)
        imageView.frame = CGRect(x: Constants.cellPaddingLeft,
                                 y: Constants.cellPaddingTop,
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
