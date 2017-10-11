//
//  GifModel.swift
//  Gifer
//
//  Created by Mikhalkov, Eugene on 10/11/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation

class GifModel {
    
    var width = 0.0
    var height = 0.0
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
            height = Double(gifHeight)!
        }
        if let gifWidth = data.width {
            width = Double(gifWidth)!
        }
    }
}
