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
    
    var width: CGFloat = 0
    var height: CGFloat = 0
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
            if let w = Double(gifWidth) {
                width = CGFloat(w)
            }
        }
        
        if let gifHeight = data["images"][Constants.preferredImageType]["height"].string {
            if let h = Double(gifHeight) {
                height = CGFloat(h)
            }
        }
        
        if let trendingDateTime = data["trending_datetime"].string {
            (trendingDateTime == Constants.nonTrendedDateTimeFormat) ? (trended = false) : (trended = true)
        }
    }
}
