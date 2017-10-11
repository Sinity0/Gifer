//
//  FeedMapper.swift
//  Gifer
//
//  Created by Mikhalkov, Eugene on 10/10/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation
import ObjectMapper

class GifMapper: NSObject, Mappable {

    var width: String?
    var height: String?
    var id: String?
    var url: String?
    var rating: String?
    var trended: Bool?
    var count: Int?
    var totalCount: Int?

    override init() {
        super.init()
    }

    convenience required init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        var trendingDateTime: String?

        id <- map["id"]
        rating <- map["rating"]
        trendingDateTime <- map["trending_datetime"]
        trended = trendingDateTime != Constants.nonTrendedDateTimeFormat
        url <- map["images.original.url"]
        width <- map["images.original.width"]
        height <- map["images.original.height"]
    }
}
