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
    
    static let cellPadding: CGFloat = 5.0
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    static let noInternetOverlayTag: Int = 2000789
    static let dateTimeFormat = "yyyy-MM-dd HH:mm:ss"
    static let nonTrendedDateTimeFormat = "0000-00-00 00:00:00"
    
    static let searchResultsLimit: Int = 400
    static let preferredSearchRating = "pg"
    static let preferredImageType = "fixed_width_downsampled"
    static let trendedIconName = "trendedIcon"
    static let trendedIconSize: CGFloat = 25
    
}
