//
//  FeedModel.swift
//  Gifer
//
//  Created by Niar on 9/27/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation
import UIKit

class FeedModel {
    
    var maxgifs = Constants.searchResultsLimit
    var currentOffset = 0
    var previousOffset = -1
    var gifsArray = [GifsModel]()
    var requesting: Bool = false
    var type: feedType = .trending
    
    enum feedType {
        case trending, search
    }
    
    init(type: feedType) {
        self.type = type
    }
    
    func clearFeed() {
        maxgifs = Constants.searchResultsLimit
        gifsArray = []
        requesting = false
        currentOffset = 0
        previousOffset = -1
    }
    
    func requestFeed(_ limit: Int, offset: Int, rating: String?, terms: String?, comletionHandler:@escaping (_ succeed: Bool, _ total: Int?, _ error: String?) -> Void) {
        if requesting {
            comletionHandler(false, nil, nil)
            return
        }
        if previousOffset == currentOffset || currentOffset >= maxgifs {
            comletionHandler(false, nil, nil)
            return
        }
        requesting = true
        
        switch type {
            
        case .trending:
            
            AlamofireManager.sharedInstance.fetchTrendingGifs(limit: limit, offset: offset, completion: { result -> Void in
                
                self.requesting = false
                
                switch result {
                    
                case .success(let value):
                    var newgifs = value
                    for newgif in newgifs {
                        if self.gifsArray.contains(where: { $0.id == newgif.id }) {
                            if let i = newgifs.index(where: { $0.id == newgif.id }) {
                                newgifs.remove(at: i)
                            }
                        }
                    }
                    self.previousOffset = self.currentOffset
                    self.currentOffset = self.currentOffset + newgifs.count
                    self.gifsArray.append(contentsOf: newgifs)
                    comletionHandler(true, newgifs.count, nil)
                    
                case .failure(let error):
                    print("Error: \(error)")

                    comletionHandler(false, nil, error.localizedDescription)
                }
                
            })
            
            
        case .search:
            
            AlamofireManager.sharedInstance.fetchSearchGifs(searchStr: terms!, limit: limit, offset: offset, rating: rating, completionHandler: {(gifs, total, error) -> Void in
                self.requesting = false
                
                if let total = total, total < self.maxgifs {
                    self.maxgifs = total
                }
                
                if let gifs = gifs {
                    
                    var newgifs = gifs
                    for newgif in newgifs {
                        if self.gifsArray.contains(where: { $0.id == newgif.id }) {
                            if let i = newgifs.index(where: { $0.id == newgif.id }) {
                                newgifs.remove(at: i)
                            }
                        }
                        if newgif.width == 0 || newgif.height == 0 {
                            if let i = newgifs.index(where: { $0.id == newgif.id }) {
                                newgifs.remove(at: i)
                            }
                        }
                    }
                    self.previousOffset = self.currentOffset
                    self.currentOffset = self.currentOffset + newgifs.count
                    self.gifsArray.append(contentsOf: newgifs)
                    comletionHandler(true, newgifs.count, nil)
                    
                } else {
                    
                    comletionHandler(false, nil, error)
                    
                }
            })
        }
    }
}
