//
//  Constants.swift
//  Gifer
//
//  Created by Niar on 9/27/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct Constants {
    
    static let cellPaddingLeft: CGFloat = 5.0
    static let cellPaddingRight: CGFloat = 5.0
    static let cellPaddingTop: CGFloat = 5.0
    static let cellPaddingBottom: CGFloat = 5.0
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
    static let screenWidth: CGFloat = UIScreen.main.bounds.width

    static let dateTimeFormat: String = "yyyy-MM-dd HH:mm:ss"
    static let nonTrendedDateTimeFormat: String = "0000-00-00 00:00:00"
    
    static let searchResultsLimit: Int = 400
    static let preferredSearchRating: String = "pg"
    static let preferredImageType: String = "fixed_width_downsampled"
    static let trendedIconName: String = "trendedIcon"
    static let trendedIconSize: CGFloat = 25
    static let gifsOnPage: Int = 20
    
}
