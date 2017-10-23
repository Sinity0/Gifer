import UIKit
import SDWebImage

struct CellInfo {
    static let cellIdentifier = "FeedControllerCell"
}

class CustomCollectionViewCell: UICollectionViewCell {

    let cellInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    private var imageView: FLAnimatedImageView = FLAnimatedImageView()
    
    public var gif: GifModel? {
        didSet {
            guard let gif = gif, let url = gif.url else { return }
            imageView.sd_setImage(with: URL(string: url))
            //guard let trended = gif.trended, trended else { return }
            trendedImageView = UIImageView(image: UIImage(named: Constants.trendedIconName))
        }
    }

    private var trendedImageView: UIImageView = UIImageView() {
        didSet {
            self.addSubview(trendedImageView)


            trendedImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                    trendedImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                    trendedImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
                    trendedImageView.widthAnchor.constraint(equalToConstant: Constants.trendedIconSize),
                    trendedImageView.heightAnchor.constraint(equalToConstant: Constants.trendedIconSize)
                ])
        }
    }
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes) 
        guard let attributes = layoutAttributes as? CustomLayoutAttributes else { return }
        addSubview(imageView)

//        imageView.frame = CGRect(x: cellInsets.left,
//                                 y: cellInsets.top,
//                                 width: attributes.gifWidth,
//                                 height: attributes.gifHeight)


        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: cellInsets.left),
//            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: cellInsets.top),
            imageView.widthAnchor.constraint(equalToConstant: attributes.gifWidth),
            imageView.heightAnchor.constraint(equalToConstant: attributes.gifHeight)
            ])

        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.animatedImage = nil
        trendedImageView.removeFromSuperview()
    }
}
