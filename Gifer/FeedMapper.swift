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

    var width = 0.0
    var height = 0.0
    var id: String?
    var url: String?
    var rating: String?
    var trended: Bool?


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
        url <- map["images.\(Constants.preferredImageType).url"]
        width <- map["images.\(Constants.preferredImageType).width"]
        height <- map["images.\(Constants.preferredImageType).height"]
    }
}
