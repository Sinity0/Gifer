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
        
        self.url = data.url
        self.id = data.id
        self.rating = data.rating
        self.trended = data.trended

        if let gifHeight = data.height {
            guard let n = Double(gifHeight) else { return }
            height = n
        }
        if let gifWidth = data.width {
            guard let n = Double(gifWidth) else { return }
            width = n
        }
    }
}
