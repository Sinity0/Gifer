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

    var currentOffset = 0
    var previousOffset = -1
    var gifsArray = [GifsModel]()
    var requesting = false
    var type: feedType = .trending
    let alamofireManager = AlamofireManager()

    enum feedType {
        case trending, search
    }

    init(type: feedType) {
        self.type = type
    }

    func clearFeed() {
        gifsArray = []
        requesting = false
        currentOffset = 0
        previousOffset = -1
    }

    func requestFeed(_ limit: Int,
                      offset: Int?,
                      rating: String?,
                       terms: String?,
            comletionHandler:@escaping (_ succeed: Bool,
                                          _ total: Int?,
                                          _ error: String?) -> Void) {
        if requesting {
            comletionHandler(false, nil, nil)
            return
        }
        requesting = true

        switch type {
        case .trending:
            alamofireManager.fetchTrendingGifs(limit: limit,
                                              offset: offset!,
                                          completion: {(gifs, total, error) -> Void in

                self.requesting = false

                if let error = error {
                    comletionHandler(false, nil, error)
                } else {
                    if let newGifs = gifs {

                        if let totalGif = total {
                            //print(totalGif)
                            if totalGif > 0 {
                                self.previousOffset = self.currentOffset
                                self.currentOffset = self.currentOffset + newGifs.count
                                self.gifsArray.append(contentsOf: newGifs)
                                comletionHandler(true, newGifs.count, nil)
                            } else {
                                comletionHandler(false, nil, nil)
                            }
                        }
                    }
                }
            })

        case .search:
            alamofireManager.fetchSearchGifs(searchStr: terms!,
                                                 limit: limit,
                                                offset: offset!,
                                                rating: rating,
                                     completionHandler: {(gifs, total, error) -> Void in
                
                self.requesting = false

                if let error = error {
                    comletionHandler(false, nil, error)
                } else {

                    if let newGifs = gifs {
                        if let totalGif = total {

                            if totalGif > 0 {
                                self.previousOffset = self.currentOffset
                                self.currentOffset = self.currentOffset + newGifs.count
                                self.gifsArray.append(contentsOf: newGifs)
                                comletionHandler(true, newGifs.count, nil)
                            } else {
                                comletionHandler(false, nil, nil)
                            }
                        }
                    }
                }
            })
        }
    }
}

