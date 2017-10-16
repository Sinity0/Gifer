//
//  Constants.swift
//  GiferN
//
//  Created by Niar on 10/13/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation

struct Constants {
    
    static let url = "https://api.giphy.com/"
    static let apiKey = "GRF3LPBmOu3x3fEleLMQFszisiodVkDG"
    
    static let cellIdentifier = "FeedControllerCell"
    
    static let cellPaddingLeft: CGFloat = 5
    static let cellPaddingTop: CGFloat = 5
    
    static let trendedImageframe = CGRect(x: cellPaddingLeft * 2,
                                          y: cellPaddingTop * 2,
                                          width: trendedIconSize,
                                          height: trendedIconSize)
    static let nonTrendedDateTimeFormat = "0000-00-00 00:00:00"
    static let preferredSearchRating = "pg"
    static let trendedIconName = "trendedIcon"
    static let viewPatternName = "Pattern"
    static let trendedIconSize: CGFloat = 25
    static let gifsRequestLimit = 20
}
