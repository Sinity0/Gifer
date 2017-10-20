import UIKit

class FeedView: UIView {

    public lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: self.frame, collectionViewLayout: self.giferLayout)
        collection.backgroundColor = .clear
        collection.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        return collection
    }()

    private var giferLayout: GiferLayout
    public lazy var refreshControl = UIRefreshControl()
    public lazy var searchBar = UISearchBar()

    weak var delegate: UICollectionViewDelegate? {
        didSet {
            self.collectionView.delegate = delegate
        }
    }

    weak var dataSource: UICollectionViewDataSource? {
        didSet {
            self.collectionView.dataSource = dataSource
        }
    }

    weak var searchDelegate: UISearchBarDelegate? {
        didSet {
            self.searchBar.delegate = searchDelegate
        }
    }

    init(frame: CGRect, collectionViewLayout layout: GiferLayout ) {
        self.giferLayout = layout
        super.init(frame: frame)

        setupCollectionView()
        setupRefreshControl()
        setupSearchBar()
    }

    func setupSearchBar() {
        self.addSubview(searchBar)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
    }

    func setupCollectionView() {
        self.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.9).isActive = true
    }

    func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(FeedController.self, action: #selector(FeedController.refreshFeed(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

