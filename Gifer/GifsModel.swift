//
//  GifsModel.swift
//  Gifer
//
//  Created by Niar on 9/26/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation
import SwiftyJSON

class GifsModel {
    
    var width = 0.0
    var height = 0.0
    var url: String?
    var id: String?
    var rating: String?
    var trended: Bool?
    
    convenience init(data: JSON) {
        self.init()
        
        if let gifId = data["id"].string {
            id = gifId
        }
        
        if let gifRating = data["rating"].string {
            rating = gifRating
        }

        if let trendingDateTime = data["trending_datetime"].string {
            trended = trendingDateTime != Constants.nonTrendedDateTimeFormat
        }

        let preferredGif = data["images"][Constants.preferredImageType]
        
        if let gifURL = preferredGif["url"].string {
            url = gifURL
        }
        
        if let gifWidth = preferredGif["width"].string {
            if let n = Double(gifWidth) {
                width = n
            }
        }
        
        if let gifHeight = preferredGif["height"].string {
            if let n = Double(gifHeight) {
                width = n
            }
        }
    }
}
