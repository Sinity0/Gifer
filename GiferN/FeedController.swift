import UIKit
import Alamofire

class FeedController: UIViewController, UICollectionViewDelegate {

    fileprivate lazy var newCollectionView: GFNCollectionView = {
        let layout = GiferLayout()
        layout.delegate = self
        let view = GFNCollectionView(frame: self.view.frame, collectionViewLayout: layout, parent: self)
        return view
    }()

    public lazy var feedView: FeedView = {
        let view = FeedView(frame: self.view.frame)
        return view
    }()

    private lazy var refreshControl = UIRefreshControl()
    private let networkManager = NetworkManager()

    fileprivate lazy var searchBar: UISearchBar = {
        return self.feedView.setupSearchBar()
    }()

//    fileprivate lazy var searchController: UISearchController = {
//        return self.feedView.setupUISearchController()
//    }()

    private var currentOffset = 0
    private var previousOffset = 0

    fileprivate var gifsDataSource = [GifModel]()
    fileprivate var requesting = false

    override func viewDidLoad() {
        super.viewDidLoad()
        baseSetup()
        setupSearchController()
        setupRefreshControl()
        loadFeed(type: .trending, term: "")
        setupInfiniteScrolling()
    }

    func baseSetup() {
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white

        view.addSubview(feedView)
    }

    func setupSearchController() {
        searchBar.delegate = self
//        searchController.delegate = self
//        searchController.searchBar.delegate = self
        definesPresentationContext = true
        navigationItem.titleView = searchBar
    }

    func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshFeed(_:)), for: .valueChanged)
        newCollectionView.addSubview(refreshControl)
    }

    func setupInfiniteScrolling() {
        newCollectionView.infiniteScrollIndicatorStyle = .white
        newCollectionView.addInfiniteScroll { collectionView in
            self.newCollectionView.performBatchUpdates({ [weak self] () in
                guard let `self` = self else { return }
                let feedType: FeedType = self.isSearching() ? .search : .trending
                self.loadFeed(type: feedType, term: self.searchBar.text ?? "")

                }, completion: { [weak self] finished -> Void  in
                    guard let `self` = self else { return }
                    self.newCollectionView.finishInfiniteScroll()
            });
        }
    }

    func processServerResponse(response: Result< [GifModel] >) {

        requesting = false

        switch response {
        case .success(let value):

            let gifCount = value.count

            if gifCount > 0 {
                previousOffset = currentOffset
                currentOffset = currentOffset + gifCount
                gifsDataSource.append(contentsOf: value)
            }

            newCollectionView.performBatchUpdates({
                var indexPaths = [IndexPath]()
                for i in (currentOffset - gifCount)..<self.currentOffset {
                    let indexPath = IndexPath(item: i, section: 0)
                    indexPaths.append(indexPath)
                }
                newCollectionView.insertItems(at: indexPaths)
            }, completion: nil)

        case .failure(let error):
            let alert = showAlert(error.localizedDescription)
            present(alert, animated: true, completion: nil)
        }
    }

    func loadFeed(type: FeedType, term: String, completionHandler: (() -> ())? = nil ) {

        if requesting {
            return
        }
        requesting = true

        switch type {
        case .trending:
            networkManager.fetchTrendedGifs(limit: Constants.gifsRequestLimit, offset: currentOffset,
                                            completionHandler: {[weak self] result -> Void in
                                                guard let `self` = self else { return }
                                                self.processServerResponse(response: result)
                                                completionHandler?()
            })
        case .search:
            networkManager.searchGifs(searchTerm: term, rating: Constants.preferredSearchRating, limit: Constants.gifsRequestLimit,
                                      offset: currentOffset, completionHandler: {[weak self] result -> Void in
                                        guard let `self` = self else { return }
                                        self.processServerResponse(response: result)
                                        completionHandler?()
            })
        }
    }

    @objc private func refreshFeed(_ sender: UIRefreshControl) {
        let feedType: FeedType = self.isSearching() ? .search : .trending
        loadFeed(type: feedType, term: searchBar.text ?? "", completionHandler: { () in
            sender.endRefreshing()
        })
    }

    fileprivate func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }

    fileprivate func isSearching() -> Bool {
        return  !searchBarIsEmpty()
    }

    fileprivate func clearFeed() {
        gifsDataSource = []
        newCollectionView.reloadData()
        newCollectionView.setContentOffset(CGPoint(x:0, y:0), animated: true)
        newCollectionView.collectionViewLayout.invalidateLayout()
        newCollectionView.layoutSubviews()
        currentOffset = 0
        previousOffset = 0
    }
}

//MARK: - Custom layout for CollectionView
extension FeedController: GiferLayoutDelegate {

    func heightOfElement( heightForGifAtIndexPath indexPath: IndexPath, fixedWidth: CGFloat) -> CGFloat {
        guard let height = gifsDataSource[indexPath.item].height, let width = gifsDataSource[indexPath.item].width else {
            return 0.0
        }
        return height * fixedWidth / width
    }
}

// MARK: UICollectionView Data Source
extension FeedController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifsDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! CustomCollectionViewCell
        cell.gif = gifsDataSource[indexPath.item]
        return cell
    }
}

// MARK: UISearchBar Delegate
extension FeedController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if isSearching() {
            clearFeed()
            guard let searchTerm = searchBar.text else { return }
            loadFeed(type: .search, term: searchTerm)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if isSearching() {
            clearFeed()
            loadFeed(type: .trending, term: "")
        }
        searchBar.text = ""
        searchBar.showsCancelButton = false
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
}

