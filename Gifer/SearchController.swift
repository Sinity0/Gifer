//
//  SearchController.swift
//  Gifer
//
//  Created by Niar on 9/26/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import UIKit

class SearchResultController: UIViewController, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    var searchTerm = ""
    lazy private var gifFeed = FeedModel(type: .search)
    private let rating = Constants.preferredSearchRating
    private let gifsRequestLimit = Constants.gifsRequestLimit
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()

        title = searchTerm

        if let layout = collectionView.collectionViewLayout as? CustomCollectionViewLayout {
            layout.delegate = self
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "MySearchControllerCell")

        if let patternImage = UIImage(named: "Pattern") {
            collectionView.backgroundColor = UIColor(patternImage: patternImage)
        }

        view.addSubview(collectionView)

        loadFeed()
    }
    
    // MARK: Subview & Orientation
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Feeds
    func loadFeed() {
        gifFeed.requestFeed(gifsRequestLimit,
                            offset: gifFeed.currentOffset,
                            rating: rating,
                             terms: searchTerm,
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

// MARK: UIScrollView Delegate
extension SearchResultController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionViewBounds = CGRect(x: 0,
                   y: collectionView.contentSize.height - Constants.screenHeight / 2,
                   width: collectionView.frame.width,
                   height: Constants.screenHeight / 2)
        if collectionView.bounds.intersects(collectionViewBounds), collectionView.contentSize.height > 0 {
            loadFeed()
        }
    }
}

// MARK: UICollectionView Data Source
extension SearchResultController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifFeed.gifsArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MySearchControllerCell", for: indexPath) as! CustomCollectionViewCell
        cell.gif = gifFeed.gifsArray[indexPath.item]
        return cell
    }
}

// MARK: CustomCollectionViewLayout Delegate
extension SearchResultController: CustomCollectionViewLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, heightForGifAtIndexPath indexPath: IndexPath, fixedWidth: Double) -> Double {
        let gif = gifFeed.gifsArray[indexPath.item]
        let gifHeight = gif.height * fixedWidth / gif.width
        return gifHeight
    }
}
