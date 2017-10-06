//
//  FeedController.swift
//  Gifer
//
//  Created by Niar on 9/28/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import UIKit
import Alamofire

class FeedController: UIViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!

    private var gifFeed: FeedModel = FeedModel(type: .trending)
    private var refreshControl: UIRefreshControl!
    private let rating: String  = Constants.preferredSearchRating

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let patternImage = UIImage(named: "Pattern") {
            view.backgroundColor = UIColor(patternImage: patternImage)
        }

        searchBar.delegate = self
        searchBar.tintColor = .white
        searchBar.backgroundImage = UIImage()
        self.view.addSubview(searchBar)

        if let layout = collectionView.collectionViewLayout as? CustomCollectionViewLayout {
            layout.delegate = self
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        collectionView.addSubview(refreshControl)

        loadFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshControl.endRefreshing()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.willRotate(to: UIApplication.shared.statusBarOrientation, duration: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if toInterfaceOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
            collectionView.contentInset = UIEdgeInsetsMake(searchBar.frame.height - Constants.cellPaddingTop,
                                                           Constants.cellPaddingLeft,
                                                           Constants.cellPaddingBottom,
                                                           Constants.cellPaddingRight)
        } else {
            collectionView.contentInset = UIEdgeInsetsMake(searchBar.frame.height + Constants.cellPaddingTop,
                                                           Constants.cellPaddingLeft,
                                                           Constants.cellPaddingBottom,
                                                           Constants.cellPaddingRight)
        }

        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Feeds
    @objc func refreshFeed() {
        gifFeed.clearFeed()
        collectionView.reloadData()
        refreshControl.endRefreshing()
        loadFeed()
    }

    func loadFeed() {
        gifFeed.requestFeed(Constants.gifsRequestLimit, offset: gifFeed.currentOffset, rating: rating, terms: nil,
                            comletionHandler: { (succeed, total, error) -> Void in
            if succeed, let total = total {
                self.collectionView.performBatchUpdates({
                    var indexPaths = [IndexPath]()
                    for i in (self.gifFeed.currentOffset - total)..<self.gifFeed.currentOffset {
                        let indexPath = IndexPath(item: i, section: 0)
                        indexPaths.append(indexPath)
                    }
                    self.collectionView.insertItems(at: indexPaths)
                }, completion: nil)
            } else if let error = error {
                let alert = self.showAlert(error)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}

// MARK: -
// MARK: CustomCollectionViewLayout Delegate
extension FeedController: CustomCollectionViewLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, heightForGifAtIndexPath indexPath: IndexPath,
                        fixedWidth: Double) -> Double {
        let gif = gifFeed.gifsArray[indexPath.item]
        let gifHeight = gif.height * fixedWidth / gif.width
        return gifHeight
    }
}

// MARK: UICollectionView Data Source
extension FeedController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifFeed.gifsArray.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        cell.gif = gifFeed.gifsArray[indexPath.item]
        return cell
    }
}

// MARK: UICollectionView Delegate
extension FeedController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.text = ""
        view.endEditing(true)
        searchBar.showsCancelButton = false
    }
}

// MARK: UIScrollView Delegate
extension FeedController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.bounds.intersects(
            CGRect(x: 0, y: collectionView.contentSize.height - Constants.screenHeight / 2,
                   width: collectionView.frame.width, height: Constants.screenHeight / 2)) &&
            collectionView.contentSize.height > 0  {
            loadFeed()
        }
    }
}

// MARK: UISearchBar Delegate
extension FeedController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchTerms = searchBar.text, searchTerms != "" {
            if let searchResultController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "SearchResultController") as? SearchController
            {
                searchResultController.searchTerms = searchTerms
                self.navigationController?.pushViewController(searchResultController, animated: true)
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        view.endEditing(true)
        searchBar.showsCancelButton = false
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
}


