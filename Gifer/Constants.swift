
import UIKit

struct Constants {

    static let url = "https://api.giphy.com/"
    static let apiKey = "GRF3LPBmOu3x3fEleLMQFszisiodVkDG"

    static let cellPaddingLeft: CGFloat = 5.0
    static let cellPaddingRight: CGFloat = 5.0
    static let cellPaddingTop: CGFloat = 5.0
    static let cellPaddingBottom: CGFloat = 5.0

    static let screenHeight: CGFloat = UIScreen.main.bounds.height
    static let screenWidth: CGFloat = UIScreen.main.bounds.width

    static let dateTimeFormat = "yyyy-MM-dd HH:mm:ss"
    static let nonTrendedDateTimeFormat = "0000-00-00 00:00:00"
    
    static let preferredSearchRating = "pg"
    static let preferredImageType = "fixed_width_downsampled"
    static let trendedIconName = "trendedIcon"
    static let trendedIconSize: CGFloat = 25.0
    static let gifsRequestLimit = 20
}
