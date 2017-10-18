import UIKit
import Alamofire

class FeedController: UIViewController, UICollectionViewDelegate, UISearchControllerDelegate {


    var collectionView: UICollectionView!
//    fileprivate lazy var collectionView: UICollectionView = {
//        let view  = FeedView()
//        view.delegate = self
//        view.dataSource = self
//        view.layoutDelegate = self
//        return view.setupUICollectionView()
//    }()

    private lazy var refreshControl = UIRefreshControl()
    private let networkManager = NetworkManager()

    fileprivate lazy var searchController: UISearchController = {
        let view = FeedView()
        return view.setupUISearchController()
    }()

    private var currentOffset = 0
    private var previousOffset = 0

    fileprivate var gifsDataSource = [GifModel]()
    fileprivate var requesting = false

    override func loadView() {
        view = FeedView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white
        
        // Setup the Search Controller
        searchController.delegate = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        
        // Current result: Fail
        let layout = GiferLayout()
        layout.delegate = self

        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        // Setup the Refresh Controll
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshFeed(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        loadFeed(type: .trending, term: "")

        // Setup Infinite scroll
        collectionView.infiniteScrollIndicatorStyle = .white
        collectionView.addInfiniteScroll { collectionView in
            collectionView.performBatchUpdates({ () in
                let feedType: FeedType = self.isSearching() ? .search : .trending
                self.loadFeed(type: feedType, term: self.searchController.searchBar.text ?? "")

            }, completion: { finished -> Void in
                collectionView.finishInfiniteScroll()
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
            
            collectionView.performBatchUpdates({
                var indexPaths = [IndexPath]()
                for i in (currentOffset - gifCount)..<self.currentOffset {
                    let indexPath = IndexPath(item: i, section: 0)
                    indexPaths.append(indexPath)
                }
                collectionView.insertItems(at: indexPaths)
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
                                            completionHandler: { result -> Void in
                                                self.processServerResponse(response: result)
                                                completionHandler?()
            })
        case .search:
            networkManager.searchGifs(searchTerm: term, rating: Constants.preferredSearchRating, limit: Constants.gifsRequestLimit,
                                      offset: currentOffset, completionHandler: { result -> Void in
                                        self.processServerResponse(response: result)
                                        completionHandler?()
            })
        }
    }
    
    @objc private func refreshFeed(_ sender: UIRefreshControl) {
        let feedType: FeedType = self.isSearching() ? .search : .trending
        loadFeed(type: feedType, term: searchController.searchBar.text ?? "", completionHandler: { () in
            sender.endRefreshing()
        })
    }

    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    fileprivate func isSearching() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    fileprivate func clearFeed() {
        gifsDataSource = []
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint(x:0, y:0), animated: true)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutSubviews()
        currentOffset = 0
        previousOffset = 0
    }
}

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
            guard let searchTerm = searchController.searchBar.text else { return }
            loadFeed(type: .search, term: searchTerm)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if isSearching() {
            clearFeed()
            loadFeed(type: .trending, term: "")
        }
            searchController.searchBar.text = ""
            searchController.searchBar.showsCancelButton = false
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.searchBar.showsCancelButton = true
        return true
    }
}

