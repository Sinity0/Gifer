//
//  SearchController.swift
//  Gifer
//
//  Created by Niar on 9/26/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import UIKit
import Alamofire

class SearchController: UIViewController{

    @IBOutlet var collectionView: UICollectionView!
    var searchTerms: String!
    private var gifFeed: FeedModel = FeedModel(type: .search)
    private let rating: String  = Constants.preferredSearchRating
    private let gifsOnPage: Int = Constants.gifsOnPage
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white
        
        if searchTerms == nil {
            searchTerms = ""
        }
        
        if searchTerms.characters.count > 15 {
            self.title = String(searchTerms.characters.prefix(15)) + "..."
        } else {
            self.title = searchTerms
        }
        self.view.backgroundColor = .white

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear

        if let layout = collectionView.collectionViewLayout as? CustomCollectionViewLayout {
            layout.delegate = self
        }

        if let patternImage = UIImage(named: "Pattern") {
            collectionView.backgroundColor = UIColor(patternImage: patternImage)
        }

        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")

        self.view.addSubview(collectionView)

        loadFeed()
    }
    
    // MARK: Subview & Orientation
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.willRotate(to: UIApplication.shared.statusBarOrientation, duration: 0)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {

        collectionView.contentInset = UIEdgeInsetsMake(Constants.cellPaddingTop,
                                                       Constants.cellPaddingLeft,
                                                       Constants.cellPaddingBottom,
                                                       Constants.cellPaddingRight)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Feeds
    func loadFeed() {
        gifFeed.requestFeed(gifsOnPage, offset: 0, rating: rating, terms: searchTerms,
                            comletionHandler: { (succeed, _, error) -> Void in
            if succeed {
                //self.loaded = true
                self.collectionView.reloadData()
                self.loadMoreFeed()
            } else if let error = error {
                let alert = self.showAlert(error)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func loadMoreFeed() {
        gifFeed.requestFeed(gifsOnPage, offset: gifFeed.currentOffset, rating: rating, terms: searchTerms,
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
                    
                })
            } else if let error = error {
                let alert = self.showAlert(error)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}

// MARK: UICollectionView Delegate
extension SearchController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

// MARK: UIScrollView Delegate
extension SearchController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.bounds.intersects(CGRect(x: 0,
                                                   y: collectionView.contentSize.height - Constants.screenHeight / 2,
                                                   width: collectionView.frame.width,
                                                   height: Constants.screenHeight / 2)) &&
            collectionView.contentSize.height > 0 {
            loadMoreFeed()
        }
    }
}

// MARK: UICollectionView Data Source
extension SearchController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifFeed.gifsArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! CustomCollectionViewCell
        cell.gif = gifFeed.gifsArray[indexPath.item]
        return cell
    }
}

// MARK: CustomCollectionViewLayout Delegate
extension SearchController: CustomCollectionViewLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, heightForGifAtIndexPath indexPath: IndexPath, fixedWidth: CGFloat) -> CGFloat {
        let gif = gifFeed.gifsArray[indexPath.item]
        let gifHeight = gif.height * fixedWidth / gif.width
        return gifHeight
    }
}
