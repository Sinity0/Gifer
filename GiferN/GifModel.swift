import Foundation

struct GifModel {
    var width: CGFloat?
    var height: CGFloat?
    var url: String?
    var id: String?
    var rating: String?
    var trended: Bool?
    
    init(data: GifMapper) {
        url = data.url
        id = data.id
        rating = data.rating
        trended = data.trended

        if let gifHeight = data.height {
            height = CGFloat(gifHeight)
        }
        if let gifWidth = data.width {
            width = CGFloat(gifWidth)
        }
    }
}
