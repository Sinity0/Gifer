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
            guard let trended = gif.trended, trended else { return }
            trendedImageView = UIImageView(image: UIImage(named: Constants.trendedIconName))
        }
    }

    private var trendedImageView: UIImageView = UIImageView() {
        didSet {
            self.addSubview(trendedImageView)

            trendedImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                trendedImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -20),
                trendedImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -70),
                trendedImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
                trendedImageView.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -50)
                ])
        }
    }
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes) 
        guard let attributes = layoutAttributes as? CustomLayoutAttributes else { return }
        imageView.backgroundColor = .gray
        addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
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
