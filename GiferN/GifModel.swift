//
//  GifModel.swift
//  GiferN
//
//  Created by Niar on 10/13/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation

class GifModel {
    
    var width: CGFloat?
    var height: CGFloat?
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
            height = CGFloat(gifHeight)
        }
        if let gifWidth = data.width {
            width = CGFloat(gifWidth)
        }
    }
}
