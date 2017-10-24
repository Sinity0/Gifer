import UIKit

class FeedController: UIViewController, UICollectionViewDelegate {

    public lazy var feedView: FeedView = {
        let layout = GiferLayout()
        layout.delegate = self
        let view = FeedView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.searchDelegate = self
        view.refreshDelegate = self
        return view
    }()

    private let networkManager = NetworkManager()

    private var currentOffset = 0
    private var previousOffset = 0

    fileprivate var gifsDataSource = [GifModel]()
    fileprivate var requesting = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(feedView)
        NSLayoutConstraint.activate([
            feedView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            feedView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            feedView.leftAnchor.constraint(equalTo: view.leftAnchor),
            feedView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])

        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isHidden = true

        loadFeed(type: .trending, term: "")
        setupInfiniteScrolling()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        feedView.collectionView.collectionViewLayout.invalidateLayout()
        feedView.collectionView.layoutSubviews()
    }

    func setupInfiniteScrolling() {
        feedView.collectionView.infiniteScrollIndicatorStyle = .white
        feedView.collectionView.addInfiniteScroll { collectionView in
            self.feedView.collectionView.performBatchUpdates({ [weak self] () in
                guard let `self` = self else { return }
                let feedType: FeedType = self.isSearching() ? .search : .trending
                self.loadFeed(type: feedType, term: self.feedView.searchBar.text)

                }, completion: { [weak self] finished -> Void  in
                    guard let `self` = self else { return }
                    self.feedView.collectionView.finishInfiniteScroll()
            });
        }
    }

    func processServerResponse(response: Result< [GifModel] >) {

        switch response {
        case .success(let value):

            let gifCount = value.count

            if gifCount > 0 {
                previousOffset = currentOffset
                currentOffset = currentOffset + gifCount
                gifsDataSource.append(contentsOf: value)
            }

            feedView.collectionView.performBatchUpdates({
                var indexPaths = [IndexPath]()
                for i in (currentOffset - gifCount)..<self.currentOffset {
                    let indexPath = IndexPath(item: i, section: 0)
                    indexPaths.append(indexPath)
                }
                feedView.collectionView.insertItems(at: indexPaths)
            }, completion: nil)

        case .failure(let error):
            let alert = showAlert(error.localizedDescription)
            present(alert, animated: true, completion: nil)
        }
    }

    func loadFeed(type: FeedType, term: String?, completionHandler: (() -> ())? = nil) {

        guard !requesting else { return }
        requesting = true

        switch type {
        case .trending:
            networkManager.fetchTrendedGifs(limit: Constants.gifsRequestLimit, offset: currentOffset,
                                            completionHandler: {[weak self] result -> Void in
                                                guard let `self` = self else { return }
                                                self.processServerResponse(response: result)
                                                self.requesting = false
                                                completionHandler?()
            })
        case .search:
            networkManager.searchGifs(searchTerm: term, rating: Constants.preferredSearchRating, limit: Constants.gifsRequestLimit,
                                      offset: currentOffset, completionHandler: {[weak self] result -> Void in
                                        guard let `self` = self else { return }
                                        self.processServerResponse(response: result)
                                        self.requesting = false
                                        completionHandler?()
            })
        }
    }

    fileprivate func isSearching() -> Bool {
        return !(feedView.searchBar.text?.isEmpty ?? true)
    }

    fileprivate func clearFeed() {
        gifsDataSource = []
        feedView.collectionView.reloadData()
        feedView.collectionView.setContentOffset(CGPoint(x:0, y:0), animated: false)
        viewDidLayoutSubviews()
        currentOffset = 0
        previousOffset = 0
    }
}

//MARK: - Custom layout for CollectionView
extension FeedController: GiferLayoutDelegate {

    func heightOfElement(heightForGifAtIndexPath indexPath: IndexPath, fixedWidth: CGFloat) -> CGFloat {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellInfo.cellIdentifier, for: indexPath) as! CustomCollectionViewCell
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
        clearFeed()
        loadFeed(type: .trending, term: "")
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.showsCancelButton = false
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
}

//MARK: Refresh feed delegate
extension FeedController: RefreshFeedDelegate {

    func refreshFeed(_ sender: UIRefreshControl) {
        let feedType: FeedType = self.isSearching() ? .search : .trending
        loadFeed(type: feedType, term: feedView.searchBar.text) { () in
            sender.endRefreshing()
        }
    }
}

