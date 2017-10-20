import UIKit

class FeedView: UIView {

    public var collectionView: UICollectionView!
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
        setupSearchBar()
        setupCollectionView()
        setupRefreshControl()

    }

    func setupSearchBar() {
        self.addSubview(searchBar)
        //searchBar.delegate = self
        //definesPresentationContext = true
        //navigationItem.titleView = searchBar
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: giferLayout)
        collectionView.backgroundColor = .clear
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        self.addSubview(collectionView)

        setupConstraintsForUICollectionView()
    }

    private func setupConstraintsForSearchBar(){
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
    }

    private func setupConstraintsForUICollectionView(){
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
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

