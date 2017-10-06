//
//  GifsModel.swift
//  Gifer
//
//  Created by Niar on 9/26/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class GifsModel {
    
    var width: Double = 0
    var height: Double = 0
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
        
        if let gifURL = data["images"][Constants.preferredImageType]["url"].string {
            url = gifURL
        }
        
        if let gifWidth = data["images"][Constants.preferredImageType]["width"].string {
            guard let n = Double(gifWidth) else { return }
            width = n
        }
        
        if let gifHeight = data["images"][Constants.preferredImageType]["height"].string {
            guard let n = Double(gifHeight) else { return }
            height = n
        }
        
        if let trendingDateTime = data["trending_datetime"].string {
            if trendingDateTime == Constants.nonTrendedDateTimeFormat {
                trended = false
            } else {
                trended = true
            }
        }
    }
}
