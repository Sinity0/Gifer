import UIKit

protocol RefreshFeedDelegate: class {
    func refreshFeed(_ sender: UIRefreshControl)
}

class FeedView: UIView {

    public lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: self.frame, collectionViewLayout: self.giferLayout)
        collection.backgroundColor = .clear
        collection.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CellInfo.cellIdentifier)
        return collection
    }()

    private var giferLayout: GiferLayout
    public lazy var refreshControl = UIRefreshControl()
    public lazy var searchBar = UISearchBar()
    weak var refreshFeedDelegate: RefreshFeedDelegate?

    weak var refreshDelegate: RefreshFeedDelegate? {
        didSet {
            self.refreshFeedDelegate = refreshDelegate
        }
    }

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

    init(frame: CGRect, collectionViewLayout layout: GiferLayout) {
        self.giferLayout = layout
        super.init(frame: frame)

        self.addSubview(collectionView)
        self.addSubview(searchBar)
        setupRefreshControll()
        createConstraints()
    }

    func setupRefreshControll() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(callRefreshDelegate(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }

    func callRefreshDelegate(_ sender: UIRefreshControl) {
        refreshFeedDelegate?.refreshFeed(sender)
    }

    func createConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: self.topAnchor),
            ])

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

