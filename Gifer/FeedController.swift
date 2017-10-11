//
//  FeedController.swift
//  Gifer
//
//  Created by Niar on 9/28/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import UIKit
import Alamofire

class FeedController: UIViewController, UISearchControllerDelegate, UICollectionViewDelegate{

    @IBOutlet var collectionView: UICollectionView!

    lazy private var gifFeed = FeedModel()
    lazy private var refreshControl = UIRefreshControl()
    private let rating = Constants.preferredSearchRating

    let searchController = UISearchController(searchResultsController: nil)

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

        if let layout = collectionView.collectionViewLayout as? CustomCollectionViewLayout {
            layout.delegate = self
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(CustomCollectionViewCell.self,
                                forCellWithReuseIdentifier: "FeedControllerCell")

        let attributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : 3.0
            ] as [NSAttributedStringKey : Any]
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
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    @objc func refreshFeed(_ sender: UIRefreshControl) {

        if isSearching(){
            gifFeed.clearFeed()
            loadFeed(type: .search,
                    terms: searchController.searchBar.text,
        completionHandler: { result -> Void in

                if !result {
                    print("Failed to refresh search.")
                } else {
                    sender.endRefreshing()
                }
            })
            collectionView.reloadData()
        } else {
            gifFeed.clearFeed()
            loadFeed(type: .trending,
                    terms: nil,
        completionHandler: { result -> Void in
                if !result {
                    print("Failed to refresh feed.")
                } else {
                    sender.endRefreshing()
                }
            })
            collectionView.reloadData()
        }
    }

    func loadFeed(type: FeedType,
                 terms: String?,
     completionHandler: @escaping (_ result: Bool) -> Void ) {

        gifFeed.requestFeed( limit: Constants.gifsRequestLimit,
                            offset: gifFeed.currentOffset,
                            rating: rating,
                             terms: terms,
                              type: type,
                  comletionHandler: { (succeed, total, error) -> Void in

            if succeed, let total = total {
                self.collectionView.performBatchUpdates({
                    var indexPaths = [IndexPath]()
                    for i in (self.gifFeed.currentOffset - total)..<self.gifFeed.currentOffset {
                        let indexPath = IndexPath(item: i, section: 0)
                        indexPaths.append(indexPath)
                    }
                    self.collectionView.insertItems(at: indexPaths)
                }, completion: { done -> Void in
                    if !done {
                        completionHandler(false)
                    } else {
                        completionHandler(true)
                    }
                })
            } else if let error = error {
                let alert = self.showAlert(error)
                self.present(alert, animated: true, completion: nil)
                completionHandler(false)
            }
        })
    }

    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isSearching() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

// MARK: - CustomCollectionViewLayout Delegate
extension FeedController: CustomCollectionViewLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView,
       heightForGifAtIndexPath indexPath: IndexPath,
                        fixedWidth: Double) -> Double {

        let gif = gifFeed.gifsArray[indexPath.item]
        let gifHeight = gif.height * fixedWidth / gif.width
        return gifHeight
    }
}

// MARK: UICollectionView Data Source
extension FeedController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
          numberOfItemsInSection section: Int) -> Int {
        return gifFeed.gifsArray.count
    }

    func collectionView(_ collectionView: UICollectionView,
                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedControllerCell",
                                                      for: indexPath) as! CustomCollectionViewCell
        cell.gif = gifFeed.gifsArray[indexPath.item]
        return cell
    }
}

// MARK: UIScrollView Delegate
extension FeedController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.bounds.intersects(
            CGRect(x: 0,
                   y: collectionView.contentSize.height - Constants.screenHeight / 2,
               width: collectionView.frame.width,
              height: Constants.screenHeight / 2)) &&
            collectionView.contentSize.height > 0  {


            if isSearching() {
                loadFeed(type: .search,
                         terms: searchController.searchBar.text,
                         completionHandler: { result -> Void in

                    if !result {
                        print("Failed to add data to feed.")
                    }
                })
            } else {
                loadFeed(type: .trending,
                         terms: "",
                         completionHandler: { result -> Void in
                    if !result {
                        print("Failed to add data to feed.")
                    }
                })
            }
        }
    }
}

// MARK: UISearchResultsUpdating Delegate
extension FeedController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
}

// MARK: UISearchBar Delegate
extension FeedController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        if isSearching() {
            gifFeed.clearFeed()
            loadFeed(type: .search,
                    terms: searchController.searchBar.text,
        completionHandler: { result -> Void in

                if !result {
                    print("Something went wrong.")
                }
            })
            collectionView.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        if isSearching() {
            gifFeed.clearFeed()
            loadFeed(type: .trending,
                    terms: nil,
        completionHandler: { result -> Void in

                if !result {
                    print("Something went wrong.")
                }
            })
            collectionView.reloadData()
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
