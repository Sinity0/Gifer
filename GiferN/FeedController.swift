
import UIKit
import Alamofire

class FeedController: UIViewController, UICollectionViewDelegate, UISearchControllerDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    private lazy var refreshControl = UIRefreshControl()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    private let networkManager = NetworkManager()
    
    private var currentOffset = 0
    private var previousOffset = 0

    fileprivate var gifsDataSource = [GifModel]()
    fileprivate var requesting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let patternImage = UIImage(named: Constants.viewPatternName) {
            view.backgroundColor = UIColor(patternImage: patternImage)
        }
        
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white
        
        // Setup the Search Controller
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        
        // Setup the Collection View
        if let layout = collectionView?.collectionViewLayout as? GiferLayout {
            layout.delegate = self
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        
        // Setup the Refresh Controll
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshFeed(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        loadFeed(type: .trending, term: "")

        // Setup Infinite scroll
        collectionView.infiniteScrollIndicatorStyle = .white
        collectionView.addInfiniteScroll { collectionView in
            collectionView.performBatchUpdates({ () in
                if self.isSearching() {
                    self.loadFeed(type: .search, term: self.searchController.searchBar.text ?? "")
                } else {
                    self.loadFeed(type: .trending, term: "")
                }
            }, completion: { finished -> Void in
                collectionView.finishInfiniteScroll()
            });
        }
    }
    
    func processServerResponse(response: Result< [GifModel] >) {

        self.requesting = false
        
        switch response {
        case .success(let value):
            
            let gifCount = value.count
            
            if gifCount > 0 {
                self.previousOffset = self.currentOffset
                self.currentOffset = self.currentOffset + gifCount
                self.gifsDataSource.append(contentsOf: value)
            }
            
            self.collectionView.performBatchUpdates({
                var indexPaths = [IndexPath]()
                for i in (self.currentOffset - gifCount)..<self.currentOffset {
                    let indexPath = IndexPath(item: i, section: 0)
                    indexPaths.append(indexPath)
                }
                self.collectionView.insertItems(at: indexPaths)
            }, completion: nil)
            
        case .failure(let error):
            let alert = self.showAlert(error.localizedDescription)
            self.present(alert, animated: true, completion: nil)
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

        if isSearching() {
            loadFeed(type: .search, term: self.searchController.searchBar.text ?? "", completionHandler: { () in
                sender.endRefreshing()
            })
        } else {
            loadFeed(type: .trending, term: "", completionHandler: { () in
                sender.endRefreshing()
            })
        }
    }

    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    fileprivate func isSearching() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    fileprivate func clearFeed() {
        gifsDataSource = []
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutSubviews()
        currentOffset = 0
        previousOffset = 0
    }

}

extension FeedController: GiferLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForGifAtIndexPath indexPath: IndexPath, fixedWidth: CGFloat) -> CGFloat {
        guard let height = gifsDataSource[indexPath.item].height, let width = gifsDataSource[indexPath.item].width else { return 0.0 }
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
            searchController.searchBar.text = ""
            searchController.searchBar.showsCancelButton = false
        } else {
            searchController.searchBar.text = ""
            searchController.searchBar.showsCancelButton = false
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.searchBar.showsCancelButton = true
        return true
    }
}

