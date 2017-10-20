import Foundation

struct Constants {
    static let urlTrending = "https://api.giphy.com/v1/gifs/trending"
    static let urlSearch = "https://api.giphy.com/v1/gifs/search"
    static let apiKey = "GRF3LPBmOu3x3fEleLMQFszisiodVkDG"
    
    static let cellIdentifier = "FeedControllerCell"

    static let cellInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)


    static let nonTrendedDateTimeFormat = "0000-00-00 00:00:00"
    static let preferredSearchRating = "pg"
    static let trendedIconName = "trendedIcon"
    static let viewPatternName = "Pattern"
    static let trendedIconSize: CGFloat = 25
    static let gifsRequestLimit = 20
}
