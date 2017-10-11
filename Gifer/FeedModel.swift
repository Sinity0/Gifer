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
    var gifsArray = [GifModel]()
    var requesting = false
    let alamofireManager = AlamofireManager()

    func clearFeed() {
        gifsArray = []
        requesting = false
        currentOffset = 0
        previousOffset = -1
    }

    func requestFeed(  limit: Int,
                       offset: Int?,
                       rating: String?,
                       terms: String?,
                       type: FeedType,
                       comletionHandler:@escaping (_ succeed: Bool,
                                                     _ total: Int?,
                                                     _ error: String?) -> Void) {

        if requesting {
            comletionHandler(true, nil, nil)
            return
        }
        requesting = true

        var searchTerm = ""
        if terms != nil {
            searchTerm = terms!
        }

        alamofireManager.fetchGifs(type: type,
                                  limit: limit,
                                 offset: offset!,
                                 rating: rating,
                              searchStr: terms,
                      completionHandler: { (gifs, total, error) -> Void in

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

                            //self.gifsArray.append(newGifs)
                            comletionHandler(true, newGifs.count, nil)
                        } else {
                            comletionHandler(true, nil, nil)
                        }
                    }
                }
            }
        })
    }
}

