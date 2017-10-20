import Foundation
import ObjectMapper

struct GifModel: Mappable {
    var width: CGFloat?
    var height: CGFloat?
    var url: String?
    var id: String?
    var rating: String?
    var trended: Bool?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        var trendingDateTime: String?
        var mapWidth: String?
        var mapHeight: String?

        id <- map["id"]
        rating <- map["rating"]
        trendingDateTime <- map["trending_datetime"]
        trended = trendingDateTime != Constants.nonTrendedDateTimeFormat
        url <- map["images.original.url"]
        mapWidth <- map["images.original.width"]
        mapHeight <- map["images.original.height"]

        if let gifHeight = mapHeight {
            height = CGFloat(gifHeight)
        }
        if let gifWidth = mapWidth {
            width = CGFloat(gifWidth)
        }
    }
}
