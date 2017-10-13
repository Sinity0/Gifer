
import UIKit
import Alamofire
import Foundation

class FeedController: UIViewController, UISearchControllerDelegate, UICollectionViewDelegate{

    @IBOutlet var collectionView: UICollectionView!

    private lazy var refreshControl = UIRefreshControl()
    private let rating = Constants.preferredSearchRating

    private let searchController = UISearchController(searchResultsController: nil)
    public typealias RequestFeedCompletion = ( _ succeed: Bool,_ total: Int?,_ error: String?) -> Void

    private var currentOffset = 0
    private var previousOffset = 0
    private var gifsArray = [GifModel]()
    private var requesting = false
    private let networkManager = NetworkManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let patternImage = UIImage(named: "Pattern") {
            view.backgroundColor = UIColor(patternImage: patternImage)
        }

        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar

//        if let layout = collectionView.collectionViewLayout as? CustomCollectionViewLayout {
//            layout.delegate = self
//        }
        if let layout = collectionView.collectionViewLayout as? CustomCollectionViewLayout{
            layout.delegate = self
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(CustomCollectionViewCell.self,
                                forCellWithReuseIdentifier: "FeedControllerCell")
        let attributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : 3.0
            ]
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",
                                                        attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshFeed(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)

        loadFeed(type: .trending,
                 terms: nil,
                 completionHandler: { result -> Void in
            if !result {
                print("Failed to load feed.")
            }
        })

        collectionView.infiniteScrollIndicatorStyle = .white
        collectionView.addInfiniteScroll { collectionView in
            collectionView.performBatchUpdates({ () in
                if self.isSearching() {
                    self.loadFeed(type: .search, terms: self.searchController.searchBar.text, completionHandler: { result -> Void in

                                if !result {
                                    print("Failed to add data to feed.")
                                }
                    })
                } else {
                    self.loadFeed(type: .trending, terms: "", completionHandler: { result -> Void in
                                if !result {
                                    print("Failed to add data to feed.")
                                }
                    })
                }
            }, completion: { (finished) -> Void in
                collectionView.finishInfiniteScroll()
            });
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    @objc private func refreshFeed(_ sender: UIRefreshControl) {

        if isSearching(){
            //clearFeed()
            loadFeed(type: .search,
                     terms: searchController.searchBar.text,
                     completionHandler: { result -> Void in


                if !result {
                    print("Failed to refresh search.")
                } else {
                    sender.endRefreshing()
                }
            })
        } else {
            //clearFeed()
            loadFeed(type: .trending,
                     terms: nil,
                     completionHandler: { result -> Void in
                if !result {
                    print("Failed to refresh feed.")
                } else {
                    sender.endRefreshing()
                }
            })

        }
    }

    func loadFeed(type: FeedType,
                  terms: String?,
                  completionHandler: @escaping (_ result: Bool) -> Void ) {

        requestFeed(limit: Constants.gifsRequestLimit,
                    offset: currentOffset,
                    rating: rating,
                    terms: terms,
                    type: type,
                    comletionHandler: { (succeed, total, error) -> Void in

            if succeed, let total = total {

                self.collectionView.performBatchUpdates({

                    var indexPaths = [IndexPath]()
                    for i in (self.currentOffset - total)..<self.currentOffset {
                        let indexPath = IndexPath(item: i, section: 0)
                        indexPaths.append(indexPath)
                    }
                    self.collectionView.insertItems(at: indexPaths)

                }, completion: { done -> Void in
                        completionHandler(done)
                })
            } else if let error = error {
                let alert = self.showAlert(error)
                self.present(alert, animated: true, completion: nil)
                completionHandler(false)
            }
        })
    }

    func requestFeedCompletionHandler (gifs: [GifModel]?, error: String? ) -> (Bool, Int?, String?) {

                self.requesting = false
                if let error = error {
                    return (false, nil, error)
                } else {
                    if let newGifs = gifs {
                        let gifCount = newGifs.count
                        if gifCount > 0 {
                            self.previousOffset = self.currentOffset
                            self.currentOffset = self.currentOffset + gifCount
                            self.gifsArray.append(contentsOf: newGifs)

                            return(true, gifCount, nil)
                        }
                    }
                }
        return(true, nil, nil)
    }

    private func requestFeed(limit: Int,
                             offset: Int?,
                             rating: String?,
                             terms: String?,
                             type: FeedType,
                             comletionHandler:@escaping RequestFeedCompletion) {

        if requesting {
            comletionHandler(true, nil, nil)
            return
        }
        requesting = true

        switch type{
        case .search:
            if let searchTerm = terms, let tableOffset = offset {
                networkManager.searchGifs(searchTerm: searchTerm,
                                          rating: rating,
                                          limit: limit,
                                          offset: tableOffset,
                                          completionHandler: {(gifs, total, error) -> Void in

                                            let res = self.requestFeedCompletionHandler(gifs: gifs, error: error)
                                            comletionHandler( res.0, res.1, res.2)
                })
            }

        case .trending:
            if let tableOffset = offset {
                networkManager.fetchTrendedGifs(limit: limit,
                                                offset: tableOffset,
                                                completionHandler: {(gifs, total, error) -> Void in

                                                    let res = self.requestFeedCompletionHandler(gifs: gifs, error: error)
                                                    comletionHandler( res.0, res.1, res.2)
                })
            }
        }
    }

    private func clearFeed() {

        gifsArray = []
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutSubviews()
        requesting = false
        currentOffset = 0
        previousOffset = 0
    }

    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    private func isSearching() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

// MARK: - CustomCollectionViewLayout Delegate
extension FeedController: CustomCollectionViewLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        heightForGifAtIndexPath indexPath: IndexPath,
                        fixedWidth: Double) -> Double {

        let gif = gifsArray[indexPath.item]

        if let height = gif.height, let width = gif.width {
            let gifHeight = height * fixedWidth / width
            return gifHeight
        }
        return 0.0
    }
}

// MARK: UICollectionView Data Source
extension FeedController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return gifsArray.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedControllerCell",
                                                      for: indexPath) as! CustomCollectionViewCell
        cell.gif = gifsArray[indexPath.item]
        return cell
    }
}

// MARK: UISearchResultsUpdating Delegate
extension FeedController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}

// MARK: UISearchBar Delegate
extension FeedController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        if isSearching() {
            clearFeed()

            loadFeed(type: .search,
                     terms: searchController.searchBar.text,
                     completionHandler: { result -> Void in

                        if !result {
                            print("Something went wrong.")
                        } else {

                        }
            })

        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        if isSearching() {
            clearFeed()
            loadFeed(type: .trending,
                     terms: nil,
                     completionHandler: { result -> Void in

                        if !result {
                            print("Something went wrong.")
                        }
            })
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


