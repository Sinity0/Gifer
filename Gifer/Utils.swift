//
//  Utils.swift
//  Gifer
//
//  Created by Niar on 9/27/17.
//  Copyright © 2017 Niar. All rights reserved.
//

import Foundation
import UIKit

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

extension UIViewController {
    
    // MARK: AlertController
    func alertControllerWithMessage(_ message: String) -> UIAlertController {
        
        let alertController = UIAlertController.init(title: "GifSearcher", message: message, preferredStyle: .alert)
        let confirm = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(confirm)
        return alertController
        
    }
    
}
