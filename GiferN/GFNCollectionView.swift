import UIKit

class GFNCollectionView: UICollectionView {

    var parentVC: FeedController?

    init(frame: CGRect, collectionViewLayout layout: GiferLayout, parent: FeedController) {
        super.init(frame: frame, collectionViewLayout: layout)
        parentVC = parent
        setupCollectionView()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCollectionView() {
        self.delegate = parentVC
        //        self.dataSource = self as? UICollectionViewDataSource
        self.dataSource = parentVC
        self.backgroundColor = .clear
        self.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
    }

    func setupConstraints() {
        guard let parentVC = parentVC else { return }
        parentVC.feedView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: parentVC.feedView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parentVC.feedView.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parentVC.feedView.bottomAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parentVC.feedView.topAnchor).isActive = true
    }
}
