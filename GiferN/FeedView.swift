import UIKit

class FeedView: UIView{

//    private var collectionView: UICollectionView!
//    private let layout = GiferLayout()
//
//    var delegate: UICollectionViewDelegate? {
//        didSet {
//            self.collectionView.delegate = delegate
//        }
//    }
//
//    var dataSource: UICollectionViewDataSource? {
//        didSet {
//            self.collectionView.dataSource = dataSource
//        }
//    }
//
//    var layoutDelegate: GiferLayoutDelegate? {
//        didSet {
//            self.layout.delegate = layoutDelegate
//        }
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        if let patternImage = UIImage(named: Constants.viewPatternName) {
            self.backgroundColor = UIColor(patternImage: patternImage)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUISearchController() -> UISearchController {
        let viewController = UISearchController(searchResultsController: nil)
        viewController.hidesNavigationBarDuringPresentation = false
        viewController.dimsBackgroundDuringPresentation = false
        viewController.obscuresBackgroundDuringPresentation = false
        return viewController
    }

//    func setupUICollectionView() -> UICollectionView {
//
//
//        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
//        collectionView.backgroundColor = .clear
//        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
//        self.addSubview(collectionView)
//
//        setupConstraintsForUICollectionView()
//        return collectionView
//    }

//    private func setupConstraintsForUICollectionView(){
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//    }
}
