
import Foundation

class GifModel {
    
    var width: Double?
    var height: Double?
    var url: String?
    var id: String?
    var rating: String?
    var trended: Bool?

    convenience init(data: GifMapper) {
        self.init()
        
        url = data.url
        id = data.id
        rating = data.rating
        trended = data.trended

        if let gifHeight = data.height {
            height = Double(gifHeight)
        }
        if let gifWidth = data.width {
            width = Double(gifWidth)
        }
    }
}
